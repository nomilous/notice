When     = require 'when'
pipeline = require 'when/pipeline'
Message  = require './message'
Validate = require './validate'

module.exports = class NotifierFactory

    constructor: (@moo) -> 

        @middleware = []

    create: (config, callback) -> 

        config ||= {}

        unless typeof config.messenger == 'function'

            throw new Error "#{@constructor.name} requires config.messenger"


        notifier = => 

            #
            # notifier() creates a new message object
            #

            message = new Message

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
            message.label       = arguments[0]
            message.description = arguments[1]


            #
            # calls the message back unless ifn't there's
            # not no middleware registered
            #

            return config.messenger message unless @middleware.length > 0


            #
            # sends it down the middleware pipeline...
            #

            functions = []  
            pipeline( for fn in @middleware
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

            ).then(

                #
                # ...and onward to the configured messenger
                #

                -> config.messenger message

                (error) -> console.log """

                    ERROR IN MESSENGER MIDDLEWARE
                    -----------------------------

                                um?

                       should probably protect 
                             from this

                      MESSAGE WILL NOT BE SENT                                

                """, error.stack, '\n'

            )


        #
        # notifier has the middleware registrar as nested function
        #

        notifier.use = (middleware) => @register middleware


        callback null, notifier


    register: (middleware) -> 

        #
        # ensure next() is called...  (this is not foolproof)
        # 

        throw new Error 'terminal middleware detected' unless Validate.middleware middleware

        #
        # it wraps the middleware into a promise/deferral
        #

        @middleware.push (msg) -> 

            #
            # next - as passed into the middleware 
            #        is the promise resolver
            #

            deferral = When.defer()
            next     = deferral.resolve
            middleware msg, next
            return deferral.promise


    valid: (fn) -> 




