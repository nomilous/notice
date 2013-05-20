config = {}

module.exports = configure = (opts = {}) ->

    config.source    = opts.source
    config.messenger = opts.messenger

    
Object.defineProperty configure, 'config',
    
    get: -> config

