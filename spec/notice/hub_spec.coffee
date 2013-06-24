io = require 'socket.io'

require('nez').realize 'Hub', (Hub, test, context, should, http, Notifier) -> 

    context 'create()', (it) -> 

        it 'is an exported function', (done) -> 

            Hub.create.should.be.an.instanceof Function
            test done

        it 'requires a name', (done) -> 

            try Hub.create()
            catch error
                error.should.match /requires hubName as string/
                test done

    
    context 'hubside pipeline', (it) -> 

        it 'is created', (done) -> 

            spy = Notifier.create
            Notifier.create = (title) -> 
                Notifier.create = spy
                title.should.equal title
                throw 'go no futher'

            try Hub.create 'title'
            catch error

                error.should.match /go no futher/
                test done


    context 'listening', (it) -> 

        MOCK = 

            #
            # mock connected socketio
            #

            configure: -> 

        http.createServer = -> 
            listen: (port, host, cb) -> setTimeout cb, 10
            address: -> address: 'ADDRESS', port: 'PORT'
            on: ->
        io.listen = -> MOCK


        

        it 'subscribes to connecting sockets', (done) -> 

            MOCK.on = (event) -> if event == 'connection' then throw 'OKGOOD1'

            try Hub.create 'name'
            catch error 
                error.should.match /OKGOOD1/
                test done

        context 'on connected socket', (it) -> 

            SENT = events: []

            SOCKET = 
                disconnected: false
                id: 'ID'
                disconnect: -> SOCKET.disconnected = true
                emit: -> SENT.events.push arguments
                on: (event, callback) -> 
                    if event == 'handshake' 
                        callback 'SECRET', REMOTE: 'CONTEXT'


            MOCK.on = (event, callback) -> if event == 'connection'

                callback SOCKET


            it 'attaches the listeng address onto the ', (done) ->

                opts = Hub.create 'name', listen: secret: 'SECRET', -> 

                    opts.hub.listening.should.eql 
                        transport: 'http'
                        address: 'ADDRESS'
                        port: 'PORT'

                    test done


            it "registers socket with hub on good handshake secret", (done) -> ->

                opts = Hub.create 'name', listen: secret: 'SECRET'
                
                opts.hub.socket.ID.should.equal SOCKET
                opts.hub.context.ID.should.eql REMOTE: 'CONTEXT'
                test done


            it 'disconnects the socket if the secret does not match', (done) -> ->

                opts = Hub.create 'name', listen: secret: 'ETRESC'

                opts.hub.should.eql socket: {}, context: {}
                SOCKET.disconnected.should.equal true
                test done


            it 'sends accept if the secret matches', (done) -> 

                SENT.events = []
                opts  = Hub.create 'name', listen: secret: 'SECRET', -> 

                    SENT.events[0].should.eql '0': 'accept'
                    test done


            it 'feeds received messages into the pipeline', (done) -> 

                spy = Notifier.create
                Notifier.create = (title) -> 
                    Notifier.create = spy

                    #
                    # spy on notice.info.normal()
                    #
                    info: normal: -> test done


                SOCKET.on = (event, callback) -> 
                    if event == 'handshake' 
                        callback 'SECRET', REMOTE: 'CONTEXT'

                    #
                    # respond to info subscription with 
                    # mock inbound info message
                    #
                    if event == 'info' then callback
                        context:
                            title: 'TITLE'
                            tenor: 'normal'

                Hub.create 'name', listen: secret: 'SECRET', -> 

                        





