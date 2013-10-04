should            = require 'should'
{_client, client} = require '../../lib/notice/client'
{_notifier}       = require '../../lib/notice/notifier'
Connector         = require '../../lib/notice/connector'

describe 'client', -> 

    beforeEach -> 
        @now = Date.now
        @opts = 
            context:
                some: 'details'
            connect: 
                secret: 'secret'
                port: 3000
                errorWait: 500
        Connector.connect = (opts) -> on: (event, handler)-> 
            if event == 'accept' then handler()

    afterEach -> 
        Date.now = @now

    context 'factory', -> 

        it 'creates a Client definition', (done) -> 

            Client = client()
            Client.create.should.be.an.instanceof Function
            done()


    context 'create()', -> 

        it 'requires clientName', (done) -> 

            Client = client()
            Client.create undefined, @opts, (error) -> 

                error.should.match /requires clientName as string/
                done()

        it 'requires unique client name', (done) -> 

            Client = client()
            Client.create 'client name', @opts, ->
            Client.create 'client name', @opts, (error) ->
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


        it 'calls connect with opts.connect', (done) -> 

            Connector.connect = (opts) ->
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
            Connector.connect = (opts) -> on: -> 
            Client = client()
            Client.create 'client name', @opts, ->

            connection = _client().clients['client name'].connection
            connection.should.eql
                state:  'pending'
                stateAt: 1
            done()


        context 'on socket event', -> 

            beforeEach -> 
                @whenEvent = {}
                @emitted   = {}
                Connector.connect = (opts) => 
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


                # it 'when connect.state is pending it updates retry tracking if retryWait is set', (done) -> 
                #     count = 0
                #     Date.now = -> ++count
                #     @opts.connect.retryWait = 10000
                #     @whenEvent['error'] = new Error 'something'
                #     Client = client()
                #     Client.create 'client name', @opts, (error, client) -> 
                #     connection = _client().clients['client name'].connection
                #     connection.should.eql
                #         state:         'retrying'
                #         stateAt:        3
                #         retryStartedAt: 2
                #         retryCount:     0
                #     done()
                # it 'when connect.state is pending it retries connect after retryWait milliseconds', (done) -> 
                #     @timeout 4000
                #     # count = 0
                #     # Date.now = -> ++count # this breaks setTimeout
                #     @opts.connect.retryWait = 1000
                #     @whenEvent['error'] = new Error 'something'
                #     Client = client()
                #     Client.create 'client name', @opts, (error, client) -> 
                #     setTimeout (->
                #         console.log 1
                #         connection = _client().clients['client name'].connection
                #         console.log connection
                #         # connection.should.eql
                #         #     state:         'retrying'
                #         #     stateAt:        3
                #         #     retryStartedAt: 2
                #         #     retryCount:     0
                #         done()
                #     ), 3000
                    


                        
            context 'connect', -> 

                it 'responds with handshake including clientname, secret, and context', (done) -> 

                    @whenEvent['connect'] = true

                    Client = client()
                    Client.create 'client name', @opts


                    @emitted.should.eql handshake: [
                        'client name'
                        'secret'
                        { some: 'details' }
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



            context 'disconnect', -> 

                it 'when connect.state is connecting it rejects and destroys the client', (done) ->
                                            #                            ########   
                                            # pending handshake - client never fully connected
                                            #

                    @whenEvent['connect'] = true
                    @whenEvent['disconnect'] = true

                    Client = client()
                    Client.create 'client name', @opts, (error) ->

                        error.should.match /failed connect or bad secret/
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





return 
should    = require 'should'

Connector = require '../../lib/notice/connector'
Notifier  = require '../../lib/notice/notifier'
Client    = require '../../lib/notice/client'
Message   = require '../../lib/notice/message'

describe 'Client', ->

    beforeEach -> 
        @connect = Connector.connect
        @create  = Notifier.create


    afterEach ->
        Connector.connect = @connect
        Notifier.create   = @create

    xcontext 'connect()', ->

        it 'makes a connection', (done) ->

            Connector.connect = (opts, callback) -> 

                opts.transport.should.equal 'https'
                opts.address.should.equal 'localhost'
                opts.port.should.equal 10001
                should.exist opts.onReconnect

                done()


            Client.connect 'title', 

                connect:
                    transport: 'https'
                    address: 'localhost'
                    port: 10001

                (error, client) -> 


    context 'onConnect()', -> 

        beforeEach ->

            # @EMITTED = {}
            # @SOCKET  = 
            #     emit: (event, args...) => @EMITTED[event] = args
            #     on: (event, callback) -> 
            # @NOTICE  = {}
            # Connector.connect = (opts, callback) => callback null, @SOCKET
            # Notifier.create = (title) => @NOTICE.title = title; return @NOTICE


        it 'creates a notifier', (done) -> 

            Notifier.create = (title) -> 

                title.should.equal 'title'
                done()

            Client.connect 'title',

                connect:
                    transport: 'https'
                    address: 'localhost'
                    port: 10001

                (error, notice) -> 



        it 'assigns final middleware to notifier', (done) -> 


            Notifier.create = (title) -> 

                notifier = {}
                Object.defineProperty notifier, 'last', 
                    set: (value) -> done()

            Connector.connect = ({onAssign}) -> 

                onAssign socket: on: ->

            Client.connect 'title',

                connect:
                    transport: 'https'
                    address: 'localhost'
                    port: 10001

                (error, notice) -> 



        it 'forwards inbound messages from the socket onto the message bus', (done) -> 

            Notifier.create = (title) -> 

                notifier = 
                    last: ->
                    info: good: (title, msg) ->

                        title.should.equal 'title'
                        msg.should.eql data: {}, direction: 'in', origin: 'origin' 
                        done()


            Connector.connect = ({onAssign}) -> 

                #
                # mock socket
                #

                onAssign socket: on: (event, listener) ->

                    if event == 'info'

                        #
                        # info message immediately 'arrives'
                        # 

                        listener(

                            {type: 'info', origin: 'origin', title: 'title', tenor: 'good'}
                            {data: {}}

                        )

            Client.connect 'title',

                connect:
                    transport: 'https'
                    address: 'localhost'
                    port: 10001

                (error, notice) -> 


        