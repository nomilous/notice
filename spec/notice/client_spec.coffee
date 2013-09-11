#require('nez').realize 'Client', (Client, test, context, Connector, Notifier, Message) -> 

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


        