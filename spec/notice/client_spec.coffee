require('nez').realize 'Client', (Client, test, context, Connector) -> 

    context 'connect()', (it) ->

        it 'makes a connection', (done) ->

            Connector.connect = (opts, callback) -> 

                opts.should.eql 

                    transport: 'https'
                    address: 'localhost'
                    port: 10001 

                test done


            Client.connect 'title', 

                transport: 'https'
                address: 'localhost'
                port: 10001

                (error, client) -> 
