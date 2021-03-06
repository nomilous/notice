{pipeline, deferred} = require 'also'
{lifecycle}    = require './capsule/lifecycle'
{undefinedArg} = require './errors'
{v1}           = require 'node-uuid'

testable                 = undefined
module.exports._notifier = -> testable
module.exports.notifier  = (config = {}) ->

    #
    # defaults
    # --------
    # 
    # * If no capsule type is defined (in config.capsule.*) than an event capsule is created.
    # * Keeps error history of 10, available via notice.serialize(2) or REST api
    # 

    config.capsule = event: {} unless config.capsule?
    config.error ||= {}
    config.error.keep ?= 10



    #
    # for builtin control capsules
    #

    config.capsule.control = {}

    testable = local = 

        capsuleTypes:      {}
        notifiers:         {}
        notifierMetrics:   {}
        middleware:        {}
        middlewareArray:   {}
        middlewareMetrics: {}
        

        create: (title, uuid = v1()) ->

            throw new Error( 
                'Notifier.create(title) requires title as string'
            ) unless typeof title is 'string'

            throw new Error(
                "Notifier.create('#{title}') is already defined"
            ) if local.middleware[title]?


            #
            # first and last middleware reserved for hub and client
            #

            first = (next) -> next(); ### null ###
            last  = (next) -> next(); ### null ###
            
            middlewareCount = 0
            local.middleware[title]        = list = {}
            local.middlewareArray[title]   = mwBus = [] 
            local.middlewareMetrics[title] = mwMetrics = {}
            local.notifierMetrics[title]   = nfMetrics = 

                #
                # * refers to capsule in the local middleware pipeline
                #

                pipeline: localMetrics = 

                    input:
                        count: 0     # capsules in
                    processing:
                        count: 0     # capsules buzy
                    output:   
                        count: 0     # capsules out (transmitted)
                    error:
                        usr: 0      # exception in user   middleware
                        sys: 0      # exception in system middleware
                    cancel:
                        usr: 0      # cancel    in user   middleware
                        sys: 0      # cancel    in system middleware

                #
                # * keep history of recent errors (config.error.keep)
                #

                errors: localErrors = 
                    recent: []


            tooManyErrorsToKeep = -> localErrors.recent.length > config.error.keep
            keepErrors = (title, type, error) -> 

                localErrors.recent.push

                    timestamp: new Date
                    error: error.toString()
                    middleware: 
                        title: title
                        type:  type

                localErrors.recent.shift() while tooManyErrorsToKeep()


            traverse = (capsule) -> 

                #
                # sends the capsule down the middleware pipeline
                # ----------------------------------------------
                # 
                # * A traversal context travels the pipeline in tandem with the capsule
                # 
                #     ie. (next, capsule, traversal) -> 
                #
                # * cache object is preloaded into each traversal
                #

                traversal       = {}
                traversal.cache = notifier.cache


                cancelled = false
                localMetrics.input.count++
                localMetrics.processing.count++

                functions = for middleware in mwBus

                    do (middleware) -> 

                        return (->) unless middleware.enabled
                        deferred (action) -> 

                            {resolve, reject, notify} = action
                            {type, title, fn} = middleware

                            next = -> process.nextTick -> resolve capsule
                            next.notify = (update) -> process.nextTick -> notify update
                            
                            next.reject = (error)  -> 

                                keepErrors title, type, error
                                localMetrics.processing.count--
                                localMetrics.error.usr++ if type == 'usr'
                                localMetrics.error.sys++ if type == 'sys'
                                process.nextTick -> reject error
                            
                            next.cancel = -> 

                                #
                                # * UNKNOWN - cancel() leaves the remaining promises dangling,
                                #             benchmarks suggest this is not a promblem.
                                # 
                                #             But it might be.
                                #

                                cancelled = true
                                localMetrics.processing.count--
                                localMetrics.cancel.usr++ if type == 'usr'
                                localMetrics.cancel.sys++ if type == 'sys'
                                process.nextTick -> 
                                    notify 
                                        _type:     'control'
                                        control:   'cancel'
                                        middleware: title
                                        capsule:    capsule

                            try 
                                fn next, capsule, traversal
                                if title == 'last' and not cancelled
                                    localMetrics.output.count++ 
                                    localMetrics.processing.count--

                            catch error
                                keepErrors title, type, error
                                localMetrics.error.usr++ if type == 'usr'
                                localMetrics.error.sys++ if type == 'sys'
                                localMetrics.processing.count--
                                reject error

                return pipeline functions


            #
            # the set of middleware has been modified
            # ---------------------------------------
            #

            reload = -> 

                mwBus.length = 0

                mwBus.push 
                    type: 'sys'
                    title: 'first'
                    enabled: true
                    fn: first

                for title of list
                    mwBus.push 
                        type: 'usr'
                        title: title
                        enabled: list[title].enabled
                        fn: list[title].fn 

                mwBus.push 
                    type: 'sys'
                    title: 'last'
                    enabled: true
                    fn: last

                middlewareCount = mwBus.length - 2

            #
            # * first load
            #

            reload()


            local.notifiers[title] = notifier = 

                got: (title) -> list[title]?

                use: (opts, fn) -> 

                    opts.enabled ?= true

                    throw undefinedArg( 
                        'opts.title and fn', 'use(opts, middlewareFn)'
                    ) unless ( 
                        opts? and opts.title? and 
                        fn? and typeof fn == 'function'
                    )

                    unless opts.first or opts.last
                        if opts.title == 'first' or opts.title == 'last'
                            process.stderr.write "notice: 'first' and 'last' are reserved middleware titles\n"
                            return

                    #
                    # * first and last can only be set once 
                    #

                    if opts.last?
                        if typeof last is 'function' and not last.toString().match /null/
                            process.stderr.write "notice: last middleware cannot be reset! Not even using the force()\n"
                            return 
                        last = fn
                        reload()
                        return

                    if opts.first?
                        if typeof first is 'function' and not first.toString().match /null/
                            process.stderr.write "notice: first middleware cannot be reset! Not even using the force()\n"
                            return 
                        first = fn
                        reload()
                        return

                    unless list[opts.title]?
                        list[opts.title] = 
                            enabled: opts.enabled
                            metrics: pending: 'metrics per middleware'
                            fn: fn
                        reload()
                        return

                    process.stderr.write "notice: middleware '#{opts.title}' already exists, use the force()\n"


                force: (opts, fn) ->

                    #
                    # * force() can replace or delete middleware
                    #

                    throw undefinedArg( 
                        'opts.title and fn', 'use(opts, middlewareFn)'
                    ) unless ( 
                        opts? and opts.title? and 
                        ( fn? and typeof fn == 'function' ) or
                        ( opts.delete? and opts.delete is true ) or 
                        ( opts.enabled? and typeof opts.enabled is 'boolean' )

                    )

                    if opts.delete and list[opts.title]?
                        delete list[opts.title]
                        reload()
                        return

                    if opts.enabled? 
                        list[opts.title].enabled = opts.enabled
                        if opts.fn? then list[opts.title].fn = opts.fn
                        reload()
                        return

                    opts.enabled ?= true
                    
                    list[opts.title] = 
                        enabled: opts.enabled
                        metrics: pending: 'metrics per middleware'
                        fn: fn

                    reload()





            
            Object.defineProperty notifier, 'uuid', 
                writable:   false
                enumerable: true
                value:      uuid

            Object.defineProperty notifier, 'title', 
                writable:   false
                enumerable: true
                value:      title

            Object.defineProperty notifier, 'serialize',
                value: (detail = 1) -> 
                    switch detail
                        when 1 
                            title:   notifier.title
                            uuid:    notifier.uuid
                            metrics: pipeline: nfMetrics.pipeline
                        when 2

                            middlewares = local.middleware[notifier.title]
                            mmetics     = local.middlewareMetrics[notifier.title]

                            title:   notifier.title
                            uuid:    notifier.uuid
                            metrics: 
                                pipeline: nfMetrics.pipeline
                                capsules: 'pending metrics per capsule definition'
                            clients: 'pending approach to deal with large numbers'
                            cache:   notifier.cache
                            errors:  nfMetrics.errors
                            middlewares: list


            #
            # create a function for pushing a raw payload into the middleware
            # ---------------------------------------------------------------
            # 
            # * not exposed on visible api, only marginally likely to remain
            #   a permanent functionality
            # 
            # * used by the hub / client to transfer inbound payload from the
            #   socket onto the middleware where the builtin first middleware
            #   capsualizes it appropriately.
            #

            Object.defineProperty notifier, 'raw', 
                #enumerated: false
                get: -> (payload) -> traverse payload


            #
            # create a function for each defined capsule type
            # -----------------------------------------------
            # 
            # * returns a promise that resolves with the capsule
            #   after it traversed all registered middleware
            # 
            # * if an error occurs on the pipeline the promise 
            #   is rejected and the remaining middlewares will
            #   not receive the capsule
            #

            for type of config.capsule
                continue if notifier[type]?
                do (type) -> 
                    notifier[type] = deferred (args...) -> 

                        {resolve, reject, notify} = args.shift()
                        payload = {}
                        
                        for arg in args
                            if (typeof arg).match /string|number/
                                if payload[type]? then payload.description = arg
                                else payload[type] = arg
                                continue
                            continue if arg instanceof Array # ignore arrays
                            for key of arg
                                continue if key == type and payload[key]?
                                payload[key] = arg[key] 
                        callback = arg if typeof arg == 'function'

                        return pipeline([
                            (       ) -> local.capsuleTypes[type].create payload
                            (capsule) -> traverse capsule

                        ]).then(
                            (capsule) -> 
                                resolve capsule
                                callback null, capsule if callback?
                            (err) -> 
                                reject err
                                callback err if callback?
                            notify
                        )
                        

            return notifier


    #
    # * create pre-defined capsule types
    #

    for type of config.capsule
        local.capsuleTypes[type] = lifecycle type, config


    return api = 

        create: local.create

