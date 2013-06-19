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


        it 'callsback on pre connected errors', (done) -> 

            spy = io.connect
            io.connect = (uri) -> 
                io.connect = spy
                on: (event, callback) -> 
                    if event == 'error' then callback new Error 'ENOCONNECT'

            Connect (error) -> 

                error.should.match /ENOCONNECT/
                test done


        it 'does not callback on post connected errors', (done) -> 

            spy = io.connect
            io.connect = (uri) -> 
                io.connect = spy
                on: (event, cb) -> 
                    if event == 'connect' then cb()
                    if event == 'error'   then setTimeout (-> cb new Error 'ENOCONNECT'), 10

            Connect (error) -> 

                should.not.exist error
                test done


