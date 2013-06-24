require('nez').realize 'Client', (Client, test, context, Connector, Notifier) -> 

    context 'connect()', (it) ->

        it 'makes a connection', (done) ->

            Connector.connect = (opts, callback) -> 

                opts.should.eql 
                    secret: undefined
                    transport: 'https'
                    address: 'localhost'
                    port: 10001 

                test done


            Client.connect 'title', 

                connect:
                    transport: 'https'
                    address: 'localhost'
                    port: 10001

                (error, client) -> 


    context 'onConnect()', (it) -> 


        SOCKET = {}
        NOTICE = {}
        Connector.connect = (opts, callback) -> callback null, SOCKET
        Notifier.create = (title) -> NOTICE.title = title; return NOTICE


        it 'creates a notifier', (done) -> 

            Client.connect 'title',

                connect:
                    transport: 'https'
                    address: 'localhost'
                    port: 10001

                (error, notice) -> 

                    notice.title.should.equal 'title'
                    test done


        it 'assigns final middleware to notifier', (done) -> 

            Client.connect 'title',

                connect:
                    transport: 'https'
                    address: 'localhost'
                    port: 10001

                (error, notice) -> 

                    notice.finally.should.be.an.instanceof Function
                    test done


