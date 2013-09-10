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

    context 'connect()', ->

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

            @EMITTED = {}
            @SOCKET  = 
                emit: (event, args...) => @EMITTED[event] = args
                on: (event, callback) -> 
            @NOTICE  = {}
            Connector.connect = (opts, callback) => callback null, @SOCKET
            Notifier.create = (title) => @NOTICE.title = title; return @NOTICE


        it 'creates a notifier', (done) -> 

            Client.connect 'title',

                connect:
                    transport: 'https'
                    address: 'localhost'
                    port: 10001

                (error, notice) -> 

                    notice.title.should.equal 'title'
                    done()


        it 'assigns final middleware to notifier', (done) -> 

            Notifier.create = (title) -> 
                notifier = {}
                Object.defineProperty notifier, 'last', 
                    set: (value) -> done()

            Client.connect 'title',

                connect:
                    transport: 'https'
                    address: 'localhost'
                    port: 10001

                (error, notice) -> 


        it 'emits outbound notifications onto the socket', (done) -> 

            @EMITTED.info = []

            Client.connect 'title',

                connect:

                    transport: 'https'
                    address: 'localhost'
                    port: 10001

                (error, notice) => 

                    #
                    # asif the notifier itself called the middleware
                    #

                    notice.last(

                        new Message

                            #
                            # context
                            # 

                            title: 'title'
                            description: 'description'
                            origin: 'origin'
                            type: 'info'
                            tenor: 'normal'
                            direction: 'out'

                            #
                            # payload
                            #

                            key1: 'value1'
                            key2: 'value2'           

                        =>

                           

                            #
                            # context as event arg1
                            #  

                            @EMITTED.info[0].should.eql

                                title: 'title'
                                description: 'description'
                                origin: 'origin'
                                type: 'info'
                                tenor: 'normal'
                                direction: 'out'

                            #
                            # payload as event arg1
                            #  

                            @EMITTED.info[1].key1.should.eql 'value1'
                            @EMITTED.info[1].key2.should.eql 'value2'
                            done()

                    )

        it 'does not emit notifications onto the socket if they are not outbound', (done) -> 

            @EMITTED.info = []

            Client.connect 'title',

                connect:

                    transport: 'https'
                    address: 'localhost'
                    port: 10001

                (error, notice) => 

                    notice.last(

                        new Message
                            title: 'title'
                            description: 'description'
                            origin: 'origin'
                            type: 'info'
                            tenor: 'normal'
                            direction: 'in'         

                        =>

                            @EMITTED.info.length.should.equal 0
                            done()


                    )

