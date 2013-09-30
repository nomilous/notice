{pipeline, deferred} = require 'also'
{message}  = require './message' 

testable                 = undefined
module.exports._notifier = -> testable
module.exports.notifier  = (config = {}) ->

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


            notifier = use: (middleware) -> 

                if typeof middleware == 'function'

                    #
                    # anonymous middleware is registered with sequence number
                    #

                    list[++regSequence] = middleware

                else

                    #
                    # titled middleware
                    #

                    throw new Error(
                        "Notifier.use(middleware) requires middleware.title and middleware.fn"
                    ) unless middleware? and middleware.title? and middleware.fn?

                    #
                    # this will overwrite existing middleware by the same title
                    #

                    list[middleware.title] = middleware.fn

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
                    notifier[type] = (payload = {}) -> 
                        payload._type = type
                        return pipeline([
                            (   ) -> local.messageTypes[type].create payload
                            (msg) -> traverse msg
                        ])
                        



            return notifier


    #
    # * create pre-defined message types
    #

    for type of config.messages
        local.messageTypes[type] = message config.messages[type]


    return api = 

        create: local.create

