io = require 'socket.io-client'

require('nez').realize 'Connect', (Connect, test, context, should) -> 

    context 'default', (it) -> 

        it 'connects to http://localhost:10001', (done) -> 

            spy = io.connect
            io.connect = (uri) -> 
                io.connect = spy
                uri.should.equal "http://localhost:10001"
                test done
                on: ->

            Connect()


        it 'callsback ERRORS before accepted handshake', (done) -> 

            spy = io.connect
            io.connect = (uri) -> 
                io.connect = spy
                on: (event, callback) -> 
                    if event == 'error' then callback new Error 'ENOCONNECT'

            Connect (error) -> 

                error.should.match /ENOCONNECT/
                test done


        it 'does not callsback ERRORS after accepted handshake', (done) -> 

            spy = io.connect
            io.connect = (uri) -> 
                io.connect = spy

                MOCKSOCKET = 

                    on: (event, cb) -> 

                        if event == 'connect' then cb()
                        if event == 'accept'  then MOCKSOCKET.handshakeReply = cb
                        if event == 'error'   then setTimeout (-> cb new Error 'ENOCONNECT'), 10 

                    emit: (event, args...) -> 

                        if event == 'handshake'

                            MOCKSOCKET.handshakeReply()

                return MOCKSOCKET


            Connect (error) -> 

                should.not.exist error
                test done




