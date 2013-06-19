ioclient = require 'socket.io-client'

module.exports = ->
    
    opts     = arguments['0'] || {}
    callback = arg for arg in arguments

    opts.port      ||=  10001
    opts.hostname  ||= 'localhost'
    opts.transport ||= 'http'

    socket    = ioclient.connect "#{ opts.transport }://#{ opts.hostname }:#{ opts.port }"
    connected = false 

    socket.on 'error', (error) -> 

        #
        # callback connect error
        #

        if typeof callback == 'function'
        
            callback error, null unless connected

    socket.on 'connect', -> 

        connected = true
        callback()
