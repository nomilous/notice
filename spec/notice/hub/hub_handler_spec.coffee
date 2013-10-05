should      = require 'should'
{handler, _Handler, _handler} = require '../../../lib/notice/hub/hub_handler'

describe 'handler', -> 
    
    beforeEach -> 
        @now = Date.now

    afterEach -> 
        Date.now = @now

    it 'is a Handler factory', (done) -> 

        HandlerClass = handler()

        HandlerClass.create.should.be.an.instanceof Function
        done()

    it 'creates a handler', (done) -> 

        HandlerClass = handler()
        instance = HandlerClass.create()

        instance.handshake.should.be.an.instanceof  Function
        instance.resume.should.be.an.instanceof     Function
        instance.disconnect.should.be.an.instanceof Function
        done()


    context 'disconnect', -> 

        before -> @HandlerClass = handler()

        beforeEach ->

            @instance = @HandlerClass.create(
                
                hubName     = 'hubname'
                @hubContext = 
                    clients: 
                        SOCKET_ID: 
                            connected:
                                state:   'connected'
                                stateAt: '1'
                    connections: -> # TODO: remove this

            )

        it """ 
                returns a function (the handler) 
                that is enclosed in a scope containing 
                the socket to be handled 

        """, (done) ->

            handle = @instance.disconnect id: 'SOCKET_ID_2'
            handle.should.be.an.instanceof Function
            done()


        it 'sets the client to disconnected', (done) -> 

            Date.now = -> 2
            handle = @instance.disconnect id: 'SOCKET_ID'
            handle()

            connected = @hubContext.clients.SOCKET_ID.connected
            connected.should.eql 
                state: 'disconnected'
                stateAt: 2
            done()



    context 'handshake', -> 

        before -> @HandlerClass = handler()

        beforeEach ->

            @instance = @HandlerClass.create(

                hubName     = 'hubname'
                @hubContext = 
                    clients: {}
                    name2id: {}
                    connections: -> # TODO: remove this
                opts = 
                    listen: 
                        secret: 'secret'

            )
        
        it 'inserts a client into the collection if the secret matches', (done) -> 

            handle = @instance.handshake 
                id: 'SOCKET_ID'
                disconnect: ->
                emit: ->

            handle 'origin name', 'secret', 'origin context'
            should.exist @hubContext.clients.SOCKET_ID
            done()


        it 'updates client connection state', (done) -> 

            Date.now = -> 2
            handle = @instance.handshake 
                id: 'SOCKET_ID'
                disconnect: ->
                emit: ->

            handle 'origin name', 'secret', 'origin context'
            connected = @hubContext.clients.SOCKET_ID.connected
            connected.should.eql 
                state: 'connected'
                stateAt: 2
            done()


        it 'creates entry in name2id index', (done) -> 

            handle = @instance.handshake 
                id: 'SOCKET_ID'
                emit: -> 
                disconnect: ->

            handle 'origin name', 'secret', 'origin context'

            @hubContext.name2id.should.eql 
                'origin name': 'SOCKET_ID'
            done()


        context 'when the secret is wrong', ->

            it 'emits rejects with bad secret', (done) -> 

                handle = @instance.handshake 
                    id: 'SOCKET_ID'
                    disconnect: ->
                    emit: (event, payload) ->
                        event.should.equal 'reject'
                        payload.should.eql reason: 'bad secret'
                        done()

                handle 'origin name', 'wrong secret', 'origin context'

            it 'disconnects', (done) -> 

                handle = @instance.handshake 
                    id: 'SOCKET_ID'
                    emit: -> 
                    disconnect: done

                handle 'origin name', 'wrong secret', 'origin context'


            it 'does not add the client to the collection', (done) -> 

                handle = @instance.handshake 
                    id: 'SOCKET_ID'
                    emit: -> 
                    disconnect: ->

                handle 'origin name', 'wrong secret', 'origin context'
                @hubContext.clients.should.eql {}
                done()


    context 'resume', -> 

        before -> @HandlerClass = handler()

        beforeEach ->

            @instance = @HandlerClass.create(

                hubName     = 'hubname'
                @hubContext = 
                    clients: {}
                    name2id: {}
                    connections: -> # TODO: remove this
                opts = 
                    listen: 
                        secret: 'secret'

            )


        it 'calls accept on right secret', (done) -> 

            @instance.accept = -> done()

            handle = @instance.resume 
                id: 'SOCKET_ID'
                emit: -> 
                disconnect: ->

            handle 'origin name', 'secret', 'origin context'




