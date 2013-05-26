config = {}

localMessenger   = require './local_messenger'
defaultMessenger = require './default_messenger'

module.exports = configure = (opts, callback) ->
    
    opts || = {}
    
    if typeof opts.source == 'undefined'

        throw new Error 'Notice.configure(opts, callback) requires config.source'

    if typeof callback != 'function'

         throw new Error 'Notice.configure(opts, callback) requires callback to receive configured notifier'

    config.source    = opts.source
    config.messenger = localMessenger.find(config.source) || opts.messenger || defaultMessenger

    return null


Object.defineProperty configure, 'config',
    
    get: -> config
