io = require 'socket.io-client'

# require('nez').realize 'Connector', (Connector, test, context, should) -> 
should   = require 'should'
Connector = require '../../lib/notice/connector'

describe 'Connector', ->

    context 'default',-> 

        it 'connects to http://localhost:10001', (done) -> 

            spy = io.connect
            io.connect = (uri) -> 
                io.connect = spy
                uri.should.equal "http://localhost:10001"
                done()
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
                done()


        context 'after accepted handshake',-> 

            before ->

                @HANDSHAKE = undefined

                spy = io.connect
                io.connect = (uri) => 

                    @MOCKSOCKET = 

                        on: (event, cb) => 

                            if event == 'connect' then cb()
                            if event == 'accept'  then @MOCKSOCKET.handshakeReply = cb
                            if event == 'error'   then setTimeout (-> 

                                io.connect = spy
                                cb new Error 'ENOCONNECT'

                            ), 10 

                        emit: (event, args...) => 

                            if event == 'handshake'

                                @HANDSHAKE = args
                                @MOCKSOCKET.handshakeReply()
                                @MOCKSOCKET.handshakeReply()  # twice for 'only callsback on first accept'

                    return @MOCKSOCKET

            it 'does not callback errors', (done) -> 

                Connector.connect secret: ' ™i ', (error) -> 

                    should.not.exist error
                    done()
                    then: ->


            it 'sends secret in handshake', (done) -> 

                @HANDSHAKE[0].should.equal ' ™i '
                done()


            it 'only callsback on first accept', (done) -> 

                count = 0

                Connector.connect secret: ' ™i ', (error, socket) -> 
                    count++
                    then: ->

                setTimeout (-> 

                    count.should.equal 1
                    done()

                ), 10


