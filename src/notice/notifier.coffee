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
                        deferred ({resolve, reject}, msg = message) -> 

                            #
                            # TODO: catch errors / reject
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
            # * TODO: if an error occurs on the pipeline the promise 
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











return
pipeline     = require 'when/pipeline'
Defer        = require('when').defer
Message      = require './message'
# Local        = require './local'
isMiddleWare = require('./decorators').isMiddleware
asResolver   = require('./decorators').asResolver



module.exports = Notifier =

    #
    # create a message pipeline and 
    # return the notifier (input) 
    # function
    # 

    create: (origin, defaultFn) -> 

        #
        # origin     - The message origin
        # 
        # defaultFn  - Default middleware receives the assembled
        #              message (After all middleware processing)
        #             

        unless typeof origin is 'string' 

            throw new Error 'Notifier.create( origin ) requires message origin as string'

        first      = []
        firstCount = undefined

        middleware = []

        last       = []
        lastCount  = undefined

        if defaultFn instanceof Function

            (isMiddleWare asResolver (fn) -> last.push fn) defaultFn

        firstCount = first.length
        lastCount  = last.length


        notifier = (title, descriptionOr, type, tenor) ->

            #
            # notifier() creates a new message object
            #

            message = new Message descriptionOr

            #
            # notifier() creates a deferral to be resolved
            # upon completion of the message's traversal
            # of the middleware pipeline
            #

            Done = Defer()


                                          #
                                          # these args could be hazardous?? 
                                          #
                                          # TODO: understand exactly what v8 does with
                                          #       args being cast into the closure. 
                                          # 
                                          #       if outside calls modify the contents 
                                          #       of the source reference while messages
                                          #       are lagged in the pipeline waiting
                                          #       for middleware that broke out with
                                          #       an async operation, 
                                          #       
                                          #       then the posibility may exist that
                                          #       the original message contents will
                                          #       be modified by any event chains that 
                                          #       are set off in the interim.
                                          # 
                                          #       um? 2> 
                                          # 
                                          #       consider a deep copy
                                          # 
                                          #       also, some kind of introspection on
                                          #       the pipeline lag may be a good idea
                                          # 
                                          # 

            message.title       = title
            message.description = descriptionOr
            message.origin      = origin
            message.type        = type
            message.tenor       = tenor



            #
            # sends it down the middleware pipeline...
            # and returns the promise handler
            #

            functions = []
            
            return pipeline( for fn in first.concat(middleware).concat last
                          # 
                          #
                          # the 'value' of fn (function reference) will 
                          # be whichever was last in the array by the 
                          # time the pipeline starts up
                          # 
                          # the pipeline would then call the last 
                          # registered middleware function over and 
                          # over 
                          # 
                          # so each reference is pushed into an array and 
                          # shifted back out in the same sequence as the 
                          # pipeline traverses 
                          #
                          #
                functions.push fn

                                        #
                                        # message, as scoped by the surrounding
                                        # notifier()'s closure, is passed into
                                        # each middleware in turn
                                        # 
                                        # 
                -> functions.shift()(  message  )
                                        # 
            ).then(                     # and then out the exit
                                        # 
                -> Done.resolve      message
                -> Done.reject.apply null, arguments
                -> Done.notify.apply null, arguments

                #
                # included a notify, 
                # 
                # But the notify input has not (yet/ifever) been made
                # abailable to the message middleware.
                #

            )

            return Done.promise


        #
        # returns with API wrap
        #

        api = (title, description) -> notifier title, description, 'info', 'normal'

        api.use   = isMiddleWare asResolver (fn) -> middleware.push fn
        api.info  = (title, description) -> notifier title, description, 'info', 'normal'
        api.event = (title, description) -> notifier title, description, 'event', 'normal'

        api.info.normal  = api.info
        api.info.good    = (title, description) -> notifier title, description, 'info', 'good'
        api.info.bad     = (title, description) -> notifier title, description, 'info', 'bad'

        api.event.normal = api.event 
        api.event.good   = (title, description) -> notifier title, description, 'event', 'good'
        api.event.bad    = (title, description) -> notifier title, description, 'event', 'bad'


        #
        # once-only register first and last middleware 
        #

        Object.defineProperty api, 'first', 
            set: isMiddleWare asResolver (fn) -> 
                return if first.length > firstCount
                first.unshift fn

        Object.defineProperty api, 'last', 
            set: isMiddleWare asResolver (fn) -> 
                return if last.length > lastCount
                last[lastCount] = fn

        return api

