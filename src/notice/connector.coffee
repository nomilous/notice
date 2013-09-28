#
# enable https connections to servers with selfsigned certs...  
#

pipeline = require 'when/pipeline'

require('https').globalAgent.options.rejectUnauthorized = false

ioclient       = require 'socket.io-client'
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

        opts.onAssign     ||= -> 
        opts.onConnect    ||= -> 
        opts.onReconnect  ||= ->
        opts.onDisconnect ||= ->


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

            unless accepted

                #
                # connection never fully established 
                # error out
                # 

                opts.onDisconnect socket: socket

                return callback new Error 'could not connect or failed secret', null

            opts.onDisconnect socket: socket


        socket.on 'accept', -> 

            #
            # accept - reply from successful handshake / secret
            #

            connected = true

            unless accepted

                accepted = true

                pipeline([

                    (        ) -> opts.onAssign  socket: socket
                    (notifier) -> callback null, notifier
                    (        ) -> opts.onConnect socket: socket
                
                ]).then(

                    (result) -> 
                    (error) -> callback error

                )



            opts.onReconnect socket: socket


        socket.on 'connect', -> 

            #
            # connect, send handshake
            # 

            socket.emit 'handshake', opts.secret || '', opts.origin

        
