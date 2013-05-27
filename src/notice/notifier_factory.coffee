When     = require 'when'
pipeline = require 'when/pipeline'

module.exports = class NotifierFactory

    constructor: (@moo) -> 

        @middleware = []

    create: (config, callback) -> 

        config ||= {}

        unless typeof config.messenger == 'function'

            throw new Error "#{@constructor.name} requires config.messenger"


        notifier = => 

            #
            # notifier formats the message
            #

            message = content: {}
            message.content.label       = arguments[0]
            message.content.description = arguments[1]


            #
            # calls the message back unless if there
            # is no middleware registered
            #

            return config.messenger message unless @middleware.length > 0


            #
            # sends it down the middleware pipeline...
            #

            functions = []
            pipeline( for fn in @middleware

                functions.unshift fn
                (msg) -> functions.pop() msg || message

            ).then(

                #
                # ...and onward to the configured messenger
                #

                (finalMessage) -> config.messenger finalMessage

                (error) -> console.log """

                    ERROR IN MESSENGER MIDDLEWARE
                    -----------------------------

                                um?
                                

                """, error.stack, '\n'

            )


        #
        # notifier has the middleware registrar as nested function
        #

        notifier.use = (fn) => @register fn


        callback null, notifier


    register: (fn) -> 

        throw new Error 'terminal middleware detected' unless @valid fn

        #
        # it wraps the middleware into a promise/deferral
        #

        @middleware.push (msg) -> 

            deferral = When.defer()
            fn msg, deferral.resolve
            deferral.promise


    valid: (fn) -> 

        #
        # pull the args from the function signature
        #

        fnArgs = fn.toString().match(

            /^function\W*\(\W*(.*)\W*,\W*(.*)\W*\)/ 

        )[1..2].map (arg) -> arg.trim()

        #
        # match for arg2(arg1) 
        #

        nextWasCalled = new RegExp "#{fnArgs[1]}\W*\\(\W*#{fnArgs[0]}\W*\\)"
        return false unless fn.toString().match nextWasCalled
        return true


