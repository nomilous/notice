config = {}

defaultSource    = require './default_source'
defaultMessenger = require './default_messenger'
localMessenger   = require './local_messenger'

module.exports = configure = (opts = {}) ->

    config.source    = opts.source      || defaultSource()
    config.messenger = localMessenger() || opts.messenger || defaultMessenger
    
Object.defineProperty configure, 'config',
    
    get: -> config
