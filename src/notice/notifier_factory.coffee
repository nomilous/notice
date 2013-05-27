module.exports = class NotifierFactory

    constructor: (@moo) -> 

    create: (config, callback) -> 

        config ||= {}

        unless typeof config.messenger == 'function'

            throw new Error "#{@constructor.name} requires config.messenger"

        callback null, -> config.messenger.apply null, arguments

            

