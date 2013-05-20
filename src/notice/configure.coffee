config = {}

defaultSource  = -> 'the calling module'

module.exports = configure = (opts = {}) ->

    config.source    = opts.source || defaultSource()
    config.messenger = opts.messenger

    
Object.defineProperty configure, 'config',
    
    get: -> config

