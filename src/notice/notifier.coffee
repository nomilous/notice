{pipeline, deferred} = require 'also'
{lifecycle}    = require './capsule/lifecycle'
{undefinedArg} = require './errors'
{v1}           = require 'node-uuid'

testable                 = undefined
module.exports._notifier = -> testable
module.exports.notifier  = (config = {}) ->

    #
    # create default capsule emitter if none defined
    #

    config.capsule = event: {} unless config.capsule?

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
            local.middleware[title] = list = {}
            local.middlewareArray[title]   = mwBus = [] 
            local.middlewareMetrics[title] = mwMetrics = {}
            local.notifierMetrics[title]   = nfMetrics = 

                #
                # * refers to capsule in the local middleware pipeline
                #

                local: localMetrics = 

                    input:    0     # capsules in
                    output:   0     # capsules out (transmitted)
                    reject:
                        usr: 0      # exception in user   middleware
                        sys: 0      # exception in system middleware
                    cancel:
                        usr: 0      # cancel    in user   middleware
                        sys: 0      # cancel    in system middleware

            traverse = (capsule) -> 

                #
                # sends the capsule down the middleware pipeline
                # ----------------------------------------------
                # 
                # * A traversal context travels the pipeline in tandem with the capsule
                # 
                #     ie. (next, capsule, traversal) -> 
                # 

                traversal = {}

                localMetrics.input++

                functions = for middleware in mwBus

                    do (middleware) -> deferred (action) -> 

                        {resolve, reject, notify} = action
                        {type, title, fn} = middleware

                        next = -> process.nextTick -> resolve capsule

                        # TODO_LINK
                        # next.info   = -> 'https://github.com/nomilous/notice/tree/develop/spec/notice#the-next-function'
                        next.notify = (update) -> process.nextTick -> notify update
                        next.reject = (error)  -> process.nextTick -> reject error
                        next.cancel = -> # TODO: terminate the promise? (later: set appropriatly in introspection structures)

                        try 
                            fn next, capsule, traversal
                            localMetrics.output++ if title == 'last'
                        catch error
                            #localMetrics.reject.usr++
                            reject error

                return pipeline functions


            #
            # the set of middleware has been modified
            # ---------------------------------------
            #

            reload = -> 

                mwBus.length = 0
                mwBus.push type: 'sys', title: 'first', fn: first
                mwBus.push type: 'usr', title: title, fn: list[title] for title of list
                mwBus.push type: 'sys', title: 'last', fn: last
                middlewareCount = mwBus.length - 2

            #
            # * first load
            #

            reload()


            local.notifiers[title] = notifier = 

                use: (opts, fn) -> 

                    throw undefinedArg( 
                        'opts.title and fn', 'use(opts, middlewareFn)'
                    ) unless ( 
                        opts? and opts.title? and 
                        fn? and typeof fn == 'function'
                    )

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
                        list[opts.title] = fn
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
                        ( opts.delete? and opts.delete is true )
                    )

                    if opts.delete and list[opts.title]?
                        delete list[opts.title]
                        reload()
                        return
                    
                    list[opts.title] = fn
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
                            metrics: nfMetrics
                        when 2

                            middlewares = local.middleware[notifier.title]
                            mmetics     = local.middlewareMetrics[notifier.title]

                            title:   notifier.title
                            uuid:    notifier.uuid
                            metrics: nfMetrics
                            middleware: for middlewareTitle of middlewares
                                
                                title:   middlewareTitle
                                metrics: mmetics




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

