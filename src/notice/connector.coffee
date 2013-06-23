ioclient = require 'socket.io-client'

module.exports =

    connect: -> 
        
        #
        # opts from arg1 or default
        #

        opts     = arguments['0'] || {}
        opts     = {} if opts instanceof Function

        #
        # callback from last arg
        #

        callback = arg for arg in arguments

        opts.port      ||=  10001
        opts.address   ||= 'localhost'
        opts.transport ||= 'http'


        #
        # flag remote side accepted handshake
        #

        accepted  = false
        connected = false
        socket    = ioclient.connect "#{ opts.transport }://#{ opts.address }:#{ opts.port }"
        



        socket.on 'error', (error) -> 

            if typeof callback == 'function'

                #
                # callback error unless handshake complete
                #
            
                callback error, null unless accepted


        socket.on 'disconnect', -> 

            connected = false

            return unless accepted

                #
                # connection never fully established 
                #

                callback new Error 'disconnect or failed secret', null



        socket.on 'accept', -> 

            #
            # accept - reply from successful handshake / secret
            #

            connected = true
            accepted  = true

            if typeof callback == 'function' 

                callback null, socket



        socket.on 'connect', -> 

            #
            # connect, send handshake
            # 

            socket.emit 'handshake', opts.secret || '', context: 'pending'

        
