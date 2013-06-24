io = require 'socket.io-client'

require('nez').realize 'Connector', (Connector, test, context, should) -> 

    context 'default', (it) -> 

        it 'connects to http://localhost:10001', (done) -> 

            spy = io.connect
            io.connect = (uri) -> 
                io.connect = spy
                uri.should.equal "http://localhost:10001"
                test done
                on: ->

            Connector.connect()


        it 'callsback ERRORS before accepted handshake', (done) -> 

            spy = io.connect
            io.connect = (uri) -> 
                io.connect = spy
                on: (event, callback) -> 
                    if event == 'error' then callback new Error 'ENOCONNECT'

            Connector.connect (error) -> 

                error.should.match /ENOCONNECT/
                test done


        context 'after accepted handshake', (it) -> 

            HANDSHAKE = undefined

            spy = io.connect
            io.connect = (uri) -> 

                MOCKSOCKET = 

                    on: (event, cb) -> 

                        if event == 'connect' then cb()
                        if event == 'accept'  then MOCKSOCKET.handshakeReply = cb
                        if event == 'error'   then setTimeout (-> 

                            io.connect = spy
                            cb new Error 'ENOCONNECT'

                        ), 10 

                    emit: (event, args...) -> 

                        if event == 'handshake'

                            HANDSHAKE = args
                            MOCKSOCKET.handshakeReply()
                            MOCKSOCKET.handshakeReply()  # twice for 'only callsback on first accept'

                return MOCKSOCKET

            it 'does not callback errors', (done) -> 


                Connector.connect secret: ' ™i ', (error) -> 

                    should.not.exist error

                    done 'and sends secret in handshake', (ok) -> 

                        HANDSHAKE[0].should.equal ' ™i '
                        test ok

                    test done


            it 'only callsback on first accept', (done) -> 

                count = 0

                Connector.connect secret: ' ™i ', (error, socket) -> count++

                setTimeout (-> 

                    count.should.equal 1
                    test done

                ), 10


