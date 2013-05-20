config = {}

defaultSource  = require './default_source'

module.exports = configure = (opts = {}) ->

    config.source    = opts.source || defaultSource()
    config.messenger = opts.messenger

    
Object.defineProperty configure, 'config',
    
    get: -> config

