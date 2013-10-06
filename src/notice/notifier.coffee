{pipeline, deferred} = require 'also'
{message}  = require './capsule/message'
{undefinedArg} = require './errors'

testable                 = undefined
module.exports._notifier = -> testable
module.exports.notifier  = (config = {}) ->

    #
    # create default message emitter if none defined
    #

    config.messages = event: {} unless config.messages?

    #
    # for builtin control messages
    #

    config.messages.control = {}

    testable = local = 

        messageTypes: {}
        middleware:   {}
        notifiers:    {}

        create: (originCode) ->
        
            throw new Error( 
                'Notifier.create(originCode) requires originCode as string'
            ) unless typeof originCode is 'string'

            throw new Error(
                "Notifier.create('#{originCode}') is already defined"
            ) if local.middleware[originCode]?

            
            middlewareCount = 0
            local.middleware[originCode] = list = {}

            traverse = (message) -> 

                #
                # sends the msg down the middleware pipeline
                # 

                return message unless middlewareCount # no middleware
                return pipeline( for title of list
                    do (title) -> 
                        deferred ({resolve, reject, notify}, msg = message) -> 

                            #
                            # TODO: (possibly)
                            #
                            # * coherently facilitate transactionality.
                            # 
                            #    eg. if 3rd middleware fails then something 
                            #        might like the opportunity to undo stuff
                            #        that the 1st and 2nd middleware did.
                            # 
                            # * handle middleware that never calls next()
                            #   or at least have queryable tracked traversal 
                            #   state and 'time in middleware' to identify 
                            #   such.
                            # 
                            # * expose notify into the each middleware to enable
                            #   tier2-hiJinx (HOWEVER:
                            #      
                            #      notify may be more appropriate as a vector
                            #      for creating acknowledgeabiliyy and/or more
                            #      advanced protocol state (rabbit-hole-hazzard)
                            #   
                            #   )
                            #

                            try list[title] (-> resolve msg), msg   #, hubs
                                                                    #
                                                                    # TODO: consider enabling access to 
                                                                    #       all hubs in this process for 
                                                                    #       the middleware handlers to
                                                                    #       switch / route capsules.
                                                                    # 
                            catch error
                                reject error
                )


            local.notifiers[originCode] = notifier = 

                use: (opts, fn) -> 

                    #
                    # TODO: can remove middleware
                    #

                    throw undefinedArg( 
                        'opts.title and fn', 'use(opts, middlewareFn)'
                    ) unless ( 
                        opts? and opts.title? and 
                        fn? and typeof fn == 'function'
                    )

                    unless list[opts.title]?

                        list[opts.title] = fn
                        middlewareCount++
                        return

                    process.stderr.write "notice: middleware '#{originCode}' already exists, use the force()"

                force: (opts, fn) ->

                    throw undefinedArg( 
                        'opts.title and fn', 'use(opts, middlewareFn)'
                    ) unless ( 
                        opts? and opts.title? and 
                        fn? and typeof fn == 'function'
                    )

                    
                    middlewareCount++ unless list[opts.title]?
                    list[opts.title] = fn



            #
            # create a function for each defined message type
            # -----------------------------------------------
            # 
            # * returns a promise that resolves with the message
            #   after it traversed all registered middleware
            # 
            # * if an error occurs on the pipeline the promise 
            #   is rejected and the remaining middlewares will
            #   not receive the message
            #   
            #

            for type of config.messages
                continue if type == 'use'
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
                            (   ) -> local.messageTypes[type].create payload
                            (msg) -> traverse msg
                        ]).then(
                            (msg) -> 
                                resolve msg
                                callback null, msg if callback?
                            (err) -> 
                                reject err
                                callback err if callback?
                            notify
                        )
                        



            return notifier


    #
    # * create pre-defined message types
    #

    for type of config.messages
        local.messageTypes[type] = message type, config


    return api = 

        create: local.create

