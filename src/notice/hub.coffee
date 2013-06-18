listen = require './listen'

module.exports.create = (hubName, opts = {}) -> 
    
    unless typeof hubName is 'string' 

        throw new Error 'Notifier.listen( hubName, opts ) requires hubName as string'

    io        = listen opts
    connected = {}

    io.on 'connection', (socket) -> 
