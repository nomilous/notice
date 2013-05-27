pipeline = require 'when/pipeline'


module.exports = class NotifierFactory

    constructor: (@moo) -> 

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
            


        callback null, notifier

            

