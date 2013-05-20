config = {}

defaultSource  = require './default_source'
localMessenger = require './local_messenger'

module.exports = configure = (opts = {}) ->

    config.source    = opts.source      || defaultSource()
    config.messenger = localMessenger() || opts.messenger

    
Object.defineProperty configure, 'config',
    
    get: -> config

