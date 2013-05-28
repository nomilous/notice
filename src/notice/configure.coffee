localMessenger   = require './local_messenger'
defaultMessenger = require './default_messenger'
NotifierFactory  = require './notifier_factory'

module.exports   = (opts, callback) ->

    opts || = {}

    if typeof opts.source == 'undefined'

        throw new Error 'Notice.configure(opts, callback) requires config.source'

    if typeof callback != 'function'

         throw new Error 'Notice.configure(opts, callback) requires callback to receive configured notifier'

    messenger = localMessenger.find( opts.source ) || 
                opts.messenger || 
                defaultMessenger

    factory = new NotifierFactory()
    factory.create  messenger, opts, callback

