pipeline     = require 'when/pipeline'
Defer        = require('when').defer
Message      = require './message'
isMiddleWare = require('./decorators').isMiddleware
asResolver   = require('./decorators').asResolver

module.exports = Factory =

    create: (origin) -> 

        unless typeof origin is 'string' 

            throw new Error 'Factory.create( origin ) require message origin as string'

        middleware = []

        notifier = (title, description, type, tenor) ->

            #
            # notifier() creates a new message object
            #

            message = new Message

            #
            # notifier() creates a deferral to be resolved
            # upon completion of the message's traversal
            # of the middleware pipeline
            #

            exit = Defer()


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
            message.description = description
            message.origin      = origin
            message.type        = type
            message.tenor       = tenor



            #
            # sends it down the middleware pipeline...
            # and returns the promise handler
            #

            functions = []

            return pipeline( for fn in middleware
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
                          # so each reference is shifted into an array and 
                          # popped back out in the same sequence as the 
                          # pipeline traverses 
                          #
                          #
                functions.unshift fn

                                        #
                                        # message, as scoped by the surrounding
                                        # notifier()'s closure, is passed into
                                        # each middleware in turn
                                        # 
                                        # 
                -> functions.pop()(  message  )
                                        # 
            ).then(                     # and then out the exit
                                        # 
                -> exit.resolve      message
                -> exit.reject.apply null, arguments
                -> exit.notify.apply null, arguments

                #
                # included a notify, 
                # 
                # But the notify input has not (yet/ifever) been made
                # abailable to the message middleware.
                #

            )

            return exit.promise


        #
        # returns with API wrap
        #

        return { 

            #
            # middleware registrar
            #

            use: isMiddleWare asResolver (fn) -> middleware.push fn

            #
            # message generators
            #

            info: 
                good:   (title, description) -> notifier title, description, 'info', 'good'
                normal: (title, description) -> notifier title, description, 'info', 'normal'
                bad:    (title, description) -> notifier title, description, 'info', 'bad'

            event: 
                good:   (title, description) -> notifier title, description, 'event', 'good'
                normal: (title, description) -> notifier title, description, 'event', 'normal'
                bad:    (title, description) -> notifier title, description, 'event', 'bad'

            #
            # more... (after some use casing)
            # 

        }


