io = require 'socket.io-client'

require('nez').realize 'Connect', (Connect, test, context, should) -> 

    context 'default', (it) -> 

        it 'connects to https://localhost:10001', (done) -> 

            spy = io.connect
            io.connect = (uri) -> 
                io.connect = spy
                uri.should.equal "https://localhost:10001"
                test done

            Connect()
