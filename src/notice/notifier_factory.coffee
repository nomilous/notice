pipeline = require 'when/pipeline'


module.exports = class NotifierFactory

    constructor: (@moo) -> 

        @pipeline = []

    create: (config, callback) -> 

        config ||= {}

        unless typeof config.messenger == 'function'

            throw new Error "#{@constructor.name} requires config.messenger"


        notifier = -> 

            #
            # notifier formats the message
            #

            message = content: {}
            message.content.label       = arguments[0]
            message.content.description = arguments[1]


            #
            # and sends it to the configured messenger
            #

            config.messenger message


        #
        # notifier has a middleware registrar
        #

        notifier.use = (fn) => @register fn 


        callback null, notifier


    register: (fn) -> 

        throw new Error 'terminal middleware detected' unless @valid fn
        @pipeline.push fn


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


