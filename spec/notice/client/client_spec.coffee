should            = require 'should'
{_client, client, connector} = require '../../../lib/notice/client'
{_notifier}       = require '../../../lib/notice/notifier'
{hostname}        = require 'os'
uuid              = require 'node-uuid' 

describe 'client', -> 

    before -> uuid.v1 = -> 'testable'

    beforeEach -> 
        @now = Date.now
        @opts = 
            context:
                some: 'details'
            connect: 
                secret:  'secret'
                adaptor: 'socket.io'
                url:     'http://localhost:3000'
                errorWait: 500
        connector.connect = (opts) -> on: (event, handler)-> 
            if event == 'accept' then handler()

    afterEach -> 
        Date.now = @now

    context 'factory', -> 

        it 'creates a Client definition', (done) -> 

            Client = client()
            Client.create.should.be.an.instanceof Function
            done()


        it 'throws when attempting to assign reserved capsule types', (done) -> 

            try Client = client capsule: connect: {}
            catch error
                error.should.match /is a reserved capsule type/
                done()

    context 'create()', -> 

        it 'requires title', (done) -> 

            Client = client()
            Client.create undefined, @opts, (error) -> 

                error.should.match /requires arg title/
                done()

        it 'requires unique client name', (done) -> 

            Client = client()
            Client.create 'client name', @opts, ->
            Client.create 'client name', @opts, (error) ->
                #console.log error
                error.should.match /is already defined/
                done()


        it 'calls back with client as notifier instance', (done) -> 

            Client = client()
            Client.create 'client name', @opts, (error, client) -> 

                client.should.equal _notifier().notifiers['client name']
                _client().clients['client name'].should.equal client
                done()

        it 'resolves with the new client instance', (done) -> 

            Client = client()
            Client.create( 'client name', @opts ).then (client) -> 

                _client().clients['client name'].should.equal client
                done()



        it 'provides a client cache for userdefined usage', (done) -> 

            Client = client()
            Client.create( 'client name', connect: url: '' ).then (client) -> 
            
                should.exist client.cache
                done()

        it 'config can assign the initial cache object', (done) -> 

            Client = client()
            Client.create
                title: 'client name'
                connect: url: ''
                cache: thing: 1
                (err, client) -> 

                    client.cache.thing.should.equal 1
                    done()


        it 'calls connect with opts.connect', (done) -> 

            connector.connect = (opts) ->
                opts.should.eql 
                    address: 'ADDRESS'
                    port:    'PORT'
                on: ->

            Client = client()
            Client.create 'client name', 
                connect: 
                    address: 'ADDRESS'
                    port:    'PORT'

            done()


        it 'sets client connection.state to pending', (done) -> 

            Date.now = -> 1
            connector.connect = (opts) -> on: -> 
            Client = client()
            Client.create 'client name', @opts, ->

            connection = _client().clients['client name'].connection
            connection.should.eql
                state:  'pending'
                stateAt: 1
            done()


        context 'transmission onto socket', -> 

            beforeEach (done) -> 
                @EMITTED = {}
                Client = client
                    capsule:
                        event: 
                            before: (done, capsule) -> 
                                capsule.$$uuid = 'testable'
                                done()
                socket = 
                    on: (event, handler) => 

                        #
                        # fake the handshake
                        #

                        switch event 
                            when 'connect' then handler()
                            when 'accept'  then handler()
                            when 'ack'     then setTimeout (=> 

                                #
                                # mock inbound ack after 50 millis
                                #

                                handler uuid: @EMITTED['capsule'].control.uuid

                            ), 50

                    emit: (event, args...) => 

                        #
                        # all emits available in tests
                        #

                        if event == 'capsule'
                            @EMITTED[event] = 
                                header:  args[0]
                                control: args[1]
                                payload: args[2]

                connector.connect = -> socket
                Client.create 'client name', @opts, (error, @client) => 

                    @client.use
                        title: 'middleware to setup test'
                        (next, capsule) -> 
                            capsule.$$set
                                routingCode: 'x'
                                protected: true
                                hidden: true
                            next()
                    done()


            it 'emits capsule as capsule event', (done) -> 

                @EMITTED = {}
                @client.event 'test', => 
                    
                    should.exist @EMITTED.capsule
                    done()


            it 'includes a header with protocol version and ))sequence number((', (done) -> 

                @EMITTED = {}
                @client.event 'test', => 

                    @EMITTED.capsule.header.should.eql [1]
                    done()

            it 'includes config body with event type, and hidden and protected property lists', (done) -> 

                @EMITTED = {}
                @client.event 'test', => 
                    #console.log @EMITTED.capsule.control

                    @EMITTED.capsule.control.should.eql 
                        type: 'event'
                        uuid: 'testable' 
                        protected: 
                            $$type: 1
                            event: 1
                            routingCode: 1
                        hidden: 
                            $$type: 1
                            routingCode: 1
                    done()

            it 'includes capsule content payload', (done) -> 

                @EMITTED = {}
                @client.event 'test event 1', => 
                    # console.log @EMITTED.capsule.payload

                    @EMITTED.capsule.payload.should.eql

                        $$type: 'event'
                        event: 'test event 1'
                        routingCode: 'x'
                        
                    done()

            it 'includes extended payload content', (done) -> 

                @EMITTED = {}
                @client.event 'test event 2', 
                    more: 'stuff'
                    also:
                        much: 
                            much:
                                much: 'more stuff'
                    => 
                        # console.log @EMITTED.capsule.payload
                        @EMITTED.capsule.payload.should.eql

                            $$type: 'event'
                            event: 'test event 2'
                            routingCode: 'x'
                            more: 'stuff'
                            also:
                                much: 
                                    much:
                                        much: 'more stuff'
                            
                        done()

        context 'boomerang', -> 


            it 'notifies on transmission'
            it 'notifies on acknowledgement'
            it 'resolves / callsback with final capsule after full hubside traversal'

            #
            # a hubside middleware can do the same - pending the final capsule via some deeper hub
            # 
            # ...fractal
            #



        context 'on socket event', -> 

            beforeEach -> 
                @whenEvent = {}
                @emitted   = {}
                connector.connect = (opts) => 
                    on: (event, handler) => 
                        if @whenEvent[event]?
                            handler @whenEvent[event]
                            @whenEvent[event] = handler # so it can be called again
                    emit: (event, args...) => 
                        @emitted[event] = args

            context 'error', -> 

                it 'when connect.state is pending it rejects and destroys the client after errorWait milliseconds', (done) -> 
                    
                    # 
                    # errorWait?
                    # 
                    # incase something is managing the process that exited because no 
                    # connection was made in such a way that it enters a tight respawn 
                    # loop effectively creating a potentially dangerous SYN flood
                    # 

                    @whenEvent['error'] = new Error 'something'
                    Client = client()
                    Client.create 'client name', @opts, (error, client) -> 

                        error.should.match /something/
                        _client().clients.should.eql {} # destroyed - no clients
                        done()

                        
            context 'connect', -> 

                it 'responds with handshake including clientname, secret, and context', (done) -> 

                    @whenEvent['connect'] = true

                    Client = client()
                    Client.create 'client name', @opts

                    @emitted.should.eql handshake: [
                        'client name'
                        'secret'
                        { some: 'details', hostname: hostname(), pid: process.pid }
                    ]
                    done()


                it 'when connect.state is pending it sets connection.state to connecting', (done) -> 

                    Date.now = -> 1
                    @whenEvent['connect'] = true

                    Client = client()
                    Client.create 'client name', @opts


                    connection = _client().clients['client name'].connection
                    connection.should.eql 
                        state:  'connecting'
                        stateAt: 1
                    done()


                it 'when connect.state is interrupted it sets the connection.state to resuming', (done) -> 

                    Date.now = -> 1
                    @whenEvent['connect'] = true
                    @whenEvent['accept'] = true
                    @whenEvent['disconnect'] = true

                    Client = client()
                    Client.create 'client name', @opts

                    @whenEvent['connect']()  # refire connect
                    connection = _client().clients['client name'].connection
                    connection.should.eql 
                        state: 'resuming'
                        stateAt: 1
                    done()



            context 'accept', -> 

                it 'when connect.state is connecting it sets connect.state to accepted', (done) -> 

                    Date.now = -> 1
                    @whenEvent['connect'] = true
                    @whenEvent['accept'] = true

                    Client = client()
                    Client.create 'client name', @opts
                    connection = _client().clients['client name'].connection
                    connection.should.eql 
                        state:  'accepted'
                        stateAt: 1
                    done()


                it 'when connect.state is connecting calls back with the accepted client', (done) -> 

                    Date.now = -> 1
                    @whenEvent['connect'] = true
                    @whenEvent['accept'] = true

                    Client = client()
                    Client.create 'client name', @opts, (error, client) -> 

                        #
                        # client is a notifier
                        #

                        client.use.should.be.an.instanceof Function
                        client.event.should.be.an.instanceof Function
                        client.connection.should.eql
                            state: 'accepted'
                            stateAt: 1
                        done()

                it 'when connect.state is resuming it sets the state to accepted and increments the interrupted count', (done) -> 

                    Date.now = -> 1
                    @whenEvent['connect'] = true
                    @whenEvent['accept'] = true
                    @whenEvent['disconnect'] = true

                    Client = client()
                    Client.create 'client name', @opts, (error) ->

                    connection = _client().clients['client name'].connection
                    #console.log connection
                    @whenEvent['connect']()  # refire
                    #console.log connection
                    @whenEvent['accept']()  # refire
                    #console.log connection
                    connection.should.eql 
                        state: 'accepted'
                        stateAt: 1
                        interruptions: 
                            count: 1
                    done()

               
                it 'when connect.state is resuming it does not callback with the accepted client', (done) -> 

                    Date.now = -> 1
                    @whenEvent['connect'] = true
                    @whenEvent['accept'] = true
                    @whenEvent['disconnect'] = true

                    Client = client()
                    Client.create 'client name', @opts, (error) ->

                        done() # would be called multiple times if this test is failing

                    @whenEvent['connect']()  # refire
                    @whenEvent['accept']()  # refire




                it 'when connect.state is resuming it informs local (middleware) of resumption'


            context 'reject', -> 

                it 'callsback and rejectes with error', (done) -> 

                    @whenEvent['reject'] = true
                    Client = client()
                    Client.create 'client name', @opts, (error) ->

                        error.should.match /notice: origin 'client name' rejected/
                        done()


            context 'disconnect', -> 

                it 'when connect.state is connecting it rejects and destroys the client', (done) ->
                                            #                            ########   
                                            # pending handshake - client never fully connected
                                            #

                    @whenEvent['connect'] = true
                    @whenEvent['disconnect'] = true

                    Client = client()
                    Client.create 'client name', @opts, (error) ->

                        error.should.match /origin 'client name' disconnected/
                        _client().clients.should.eql {}  # destroyed - no clients
                        done()

                it 'when connect.state is accepted it sets state to interrupted', (done) ->
                                            #
                                            # handshake already succeeded
                                            #

                    Date.now = -> 1                      
                    @whenEvent['connect'] = true
                    @whenEvent['accept'] = true
                    @whenEvent['disconnect'] = true
                    Client = client()
                    Client.create 'client name', @opts, (error) ->

                    connection = _client().clients['client name'].connection
                    connection.should.eql
                        state:  'interrupted'
                        stateAt: 1
                    done()


                it 'when connect.state is accepted it informs local (middleware) of interruption'


        