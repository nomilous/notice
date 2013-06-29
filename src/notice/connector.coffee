#
# enable https connections to servers with selfsigned certs...  
#

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

                return callback new Error 'disconnect or failed secret', null


        socket.on 'accept', -> 

            #
            # accept - reply from successful handshake / secret
            #

            connected = true

            unless accepted

                #
                # new connection
                #

                accepted = true
                callback null, socket if typeof callback == 'function'
                return

            #
            # recovered connection
            #  

            console.log 'TODO: handle recovered connection!'



        socket.on 'connect', -> 

            #
            # connect, send handshake
            # 

            socket.emit 'handshake', opts.secret || '', context: 'pending'

        
