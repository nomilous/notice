{pipeline, deferred} = require 'also'
{lifecycle}          = require './capsule/lifecycle'
{health}             = require '../api/health'
{middleware}         = require '../api/middleware'
{v1}                 = require 'node-uuid'

{undefinedArg, invalidAction} = require './errors'

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
    # for builtin capsules
    # --------------------
    # 
    # * $control - internal events 
    # * $delta   - emitted on changed component (##undecided3)
    #               
    #               eg. $delta 'middleware', {authenticEntity:{},context:{},from:{},to:{}}
    #               where does it go exactly? pertinent: https://github.com/nomilous/phrase/commit/84a1e6e8afc21b58e7c3b1bcccc8d136032692e4
    # 
    # * $tick    - configureable ticker
    # * $health  - periodic process health stats
    #

    config.capsule.$control = {}
    config.capsule.$delta   = {}
    config.capsule.$tick    = {}
    config.capsule.$health  = 
        before: (done, capsule) -> 
            health capsule, -> done()


    testable = local = 

        capsuleTypes:      {}
        notifiers:         {}
        notifierMetrics:   {}
        middleware:        {}

        create: (title, uuid = v1()) ->

            throw new Error( 
                'Notifier.create(title) requires title as string'
            ) unless typeof title is 'string'

            throw new Error(
                "Notifier.create('#{title}') is already defined"
            ) if local.middleware[title]?

                                #
                                # TODO: key on uuid, but ensure unique title
                                #
            local.middleware[title]        = collection = middleware config
                                                #
                                                # the collection of middleware for the 
                                                # given notifier (hub)
                                                # 


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
                        term:
                            usr: 0      # terminal exception in user   middleware
                            sys: 0      # terminal exception in system middleware
                        pass:
                            usr: 0      # ignored (per config, pending)
                            sys: 0
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
                traversal.tools = notifier.tools

                #
                # ##undecided3 
                # 
                # * middleware access to all local "inprocess" hubs 
                #      * already have superscope on a common ancestor hub defn
                #      * per the factory of factories approach employed here
                # 
                # * to enable capsule to ""jump"" into a parallel hub's pipeline
                # * a possible vector to enable phrase tree as hub star without specific client uplinks
                #       * bear in mind - it's a stop gap pending freedom from the limitation of 
                #                        one uplink per process, all the wrk to implement alternative
                #                        to the socket.io client can hopefully be done later
                #       * bear in mind - socket.io is vital, or at least, the websocket capacity is vital
                #                        (the viewport is the most important leaf type on the whole tree)
                #                        (infact,  viewports are the flowers)
                # 
                # 
                # traversal.hubs = allLocalHubs() # or something


                cancelled = false
                localMetrics.input.count++
                localMetrics.processing.count++

                functions = for mware in collection.running()

                    do (mware) -> 

                        deferred (action) -> 

                            {resolve, reject, notify} = action
                            {type, title, fn} = mware

                                                #
                                                # TODO: how many traversals per second does it
                                                #       take to wedge the scheduler...??
                                                # 
                                                #       and what does a wedged scheduler look like
                                                #       from the outside (here)
                                                # 
                                                #       do the nextTicks just not happen? (silently?)
                                                # 
                                                # 1
                            next = -> process.nextTick -> resolve capsule
                                                        # 2
                            next.notify = (update) -> process.nextTick -> notify update
                            
                            next.reject = (error)  -> 

                                keepErrors title, type, error
                                localMetrics.processing.count--
                                localMetrics.error.term.usr++ if type == 'usr'
                                localMetrics.error.term.sys++ if type == 'sys'
                                            # 3 
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
                                            # 4
                                process.nextTick -> 
                                    notify 
                                        _type:     'control'
                                        control:   'cancel'
                                        middleware: title
                                        capsule:    capsule

                            try 

                                # console.log BUG_1_JUST_BEFORE capsule.$all

                                fn next, capsule, traversal
                                if title == 'last' and not cancelled
                                    localMetrics.output.count++ 
                                    localMetrics.processing.count--

                            catch error
                                keepErrors title, type, error
                                localMetrics.error.term.usr++ if type == 'usr'
                                localMetrics.error.term.sys++ if type == 'sys'
                                localMetrics.processing.count--
                                reject error


                return pipeline functions


            local.notifiers[title] = notifier = 

                use: (opts, fn) -> 

                    return collection.update opts if opts.update is true

                    opts.enabled ?= true

                    throw undefinedArg( 
                        'opts.title and fn', 'use()'
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

                    return collection.last  fn if opts.last?
                    return collection.first fn if opts.first?

                    collection.create

                        slot:        opts.slot
                        title:       opts.title
                        description: opts.description
                        enabled:     opts.enabled
                        fn:          fn

            
            Object.defineProperty notifier, 'uuid', 
                writable:   false
                enumerable: true
                value:      uuid

            Object.defineProperty notifier, 'title', 
                writable:   false
                enumerable: true
                value:      title

            #
            # TODO: test these 
            #
            Object.defineProperty notifier, 'uniqueTitle',
                get: -> (title) ->
                    list = collection.list()
                    for slot of list
                        return false if list[slot].title is title
                    true

            Object.defineProperty notifier, 'lastSlot',
                get: -> 
                    list = collection.list()
                    slot for slot of list
                    return slot

            Object.defineProperty notifier, 'emptySlot',
                get: -> (slot) ->
                    list = collection.list()
                    for got of list
                        return false if slot is parseInt got
                        ### note: throws if not int ###
                    return true


            Object.defineProperty notifier, 'serialize',
                value: (detail = 1) -> 
                    switch detail
                        when 1 
                            title:   notifier.title
                            uuid:    notifier.uuid
                            stats:   pipeline: nfMetrics.pipeline
                        when 2

                            middlewares = local.middleware[notifier.title]

                            title:   notifier.title
                            uuid:    notifier.uuid
                            stats: 
                                pipeline: nfMetrics.pipeline
                            cache:   notifier.cache
                            tools:   notifier.tools
                            errors:  nfMetrics.errors
                            middlewares: collection.list()


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

            Object.defineProperty notifier, '$raw', 
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

