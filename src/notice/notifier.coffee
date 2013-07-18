pipeline     = require 'when/pipeline'
Defer        = require('when').defer
Message      = require './message'
Local        = require './local'
task         = require './task'
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

        #
        # load personal message middleware from 
        # $HOME/.notice/middleware (if present)
        #

        if Local()[origin]? 

            # 
            # override defaultFn if $HOME/.notice/middleware defined
            # 'origin': function(msg, next) { ... 
            #

            (isMiddleWare asResolver (fn) -> last.push fn) Local()[origin].fn

        else if defaultFn instanceof Function

            (isMiddleWare asResolver (fn) -> last.push fn) defaultFn

        if Local().all? then (

            isMiddleWare asResolver (fn) -> last.push fn

        ) Local().all

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

        api.task         = (title, opts) -> task.create notifier, title, opts
        


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

