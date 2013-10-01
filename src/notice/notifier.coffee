{pipeline, deferred} = require 'also'
{message}  = require './message' 

testable                 = undefined
module.exports._notifier = -> testable
module.exports.notifier  = (config = {}) ->

    #
    # create default message emitter if none defined
    #

    config.messages = event: {} unless config.messages?

    testable = local = 

        messageTypes: {}
        middleware:   {}

        create: (originCode) ->
        
            throw new Error( 
                'Notifier.create(originCode) requires originCode as string'
            ) unless typeof originCode is 'string'

            throw new Error(
                "Notifier.create('#{originCode}') is already defined"
            ) if local.middleware[originCode]?

            
            regSequence = 0
            local.middleware[originCode] = list = {}

            traverse = (message) -> 

                #
                # sends the msg down the middleware pipeline
                # 

                return message unless regSequence # no middleware
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

                            try list[title] msg, -> resolve msg
                            catch error
                                reject error
                )


            notifier = use: (opts, fn) -> 

                if typeof opts == 'function'

                    #
                    # anonymous middleware is registered with sequence number
                    #

                    list[++regSequence] = opts

                else

                    #
                    # titled middleware
                    #

                    throw new Error(
                        "Notifier.use(opts, fn) requires opts.title and fn"
                    ) unless ( 
                        opts? and opts.title? and 
                        fn? and typeof fn == 'function'
                    )

                    #
                    # this will overwrite existing middleware by the same title
                    #

                    list[opts.title] = fn

                    #
                    # although the sequence was not used as key in the list
                    # it should still be incremented to inform the presence
                    # of middleware
                    #

                    regSequence++


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
                        payload._type = type

                        for arg in args
                            if (typeof arg).match /string|number/
                                payload[type] = arg unless payload[type]?
                                continue
                            continue if arg instanceof Array # ignore arrays
                            payload[key] = arg[key] for key of arg
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
        local.messageTypes[type] = message config.messages[type]


    return api = 

        create: local.create

