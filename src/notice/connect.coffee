ioclient = require 'socket.io-client'

module.exports = ->
    
    opts     = arguments['0'] || {}
    callback = arg for arg in arguments

    opts.port      ||=  10001
    opts.hostname  ||= 'localhost'
    opts.transport ||= 'http'


    #
    # flag remote side accepted handshake
    #

    accepted  = false 
    socket    = ioclient.connect "#{ opts.transport }://#{ opts.hostname }:#{ opts.port }"
    



    socket.on 'error', (error) -> 

        if typeof callback == 'function'

            #
            # callback error unless handshake complete
            #
        
            callback error, null unless accepted




    socket.on 'accept', -> 

        #
        # accept - reply from successful handshake / secret
        #

        accepted = true
        if typeof callback == 'function' then callback()




    socket.on 'connect', -> 

        #
        # connect, send handshake
        # 

        socket.emit 'handshake', opts.secret || '', context: 'pending'

    
