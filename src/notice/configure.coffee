config = {}

localMessenger   = require './local_messenger'
defaultMessenger = require './default_messenger'

module.exports = configure = (opts = {}) ->

    if typeof opts.source == 'undefined'

        throw new Error 'Notice.configure(opts) requires opts.source'

    config.source    = opts.source
    config.messenger = localMessenger() || opts.messenger || defaultMessenger


Object.defineProperty configure, 'config',
    
    get: -> config
