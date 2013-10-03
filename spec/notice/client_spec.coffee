should            = require 'should'
{_client, client} = require '../../lib/notice/client'
{_notifier}       = require '../../lib/notice/notifier'
Connector         = require '../../lib/notice/connector'

describe 'client', -> 

    beforeEach -> 
        Connector.connect = (opts) -> on: ->


    context 'factory', -> 

        it 'creates a Client definition', (done) -> 

            Client = client()
            Client.create.should.be.an.instanceof Function
            done()


    context 'create()', -> 

        it 'requires clientName', (done) -> 

            Client = client()
            Client.create undefined, {}, (error) -> 

                error.should.match /requires clientName as string/
                done()

        it 'requires unique client name', (done) -> 

            Client = client()
            Client.create 'client name'
            Client.create 'client name', {}, (error) ->

                error.should.match /is already defined/
                done()


        it 'calls back with client as notifier instance', (done) -> 

            Client = client()
            Client.create 'client name', {}, (error, client) -> 

                client.should.equal _notifier().notifiers['client name']
                _client().clients['client name'].should.equal client
                done()

        it 'resolves with the new client instance', (done) -> 

            Client = client()
            Client.create( 'client name' ).then (client) -> 

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


        context 'on socket event', -> 

            beforeEach -> 
                @whenEvent = {}
                @emitted   = {}
                Connector.connect = (opts) => 
                    on: (event, handler) => 
                        handler @whenEvent[event] if @whenEvent[event]?
                    emit: (event, args...) => 
                        @emitted[event] = args
                        

            it.only 'connect - responds with handshake including clientname, secret, and context', (done) -> 

                @whenEvent['connect'] = true

                Client = client()
                Client.create 'client name', 
                    connect:
                        secret: 'secret'
                        port:   10101
                    context: 
                        some: 'details'

                @emitted.should.eql handshake: [
                    'client name'
                    'secret'
                    { some: 'details' }
                ]
                done()















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


        