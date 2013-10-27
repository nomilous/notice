should      = require 'should'
{handler, _Handler, _handler} = require '../../../lib/notice/hub/hub_handler'
{_capsule} = require '../../../lib/notice/capsule/capsule'

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
        instance = HandlerClass.create(

            hubName     = 'hubname'
            hubNotifier = 
                $raw: ->
                use: ->

        )


        instance.handshake.should.be.an.instanceof  Function
        instance.resume.should.be.an.instanceof     Function
        instance.disconnect.should.be.an.instanceof Function
        done()

    context 'inbound socket interface -', -> 

        it 'is a middleware registered first in the pipeline', (done) -> 

            HandlerClass = handler()
            instance = HandlerClass.create(

                hubName     = 'hubname'
                hubNotifier = 
                    $raw: ->
                    use: (opts, fn) ->

                        if opts.title == 'inbound socket interface'
                            opts.first.should.equal true
                            done()

            )



        context 'first middleware', -> 


            beforeEach -> 

                HandlerClass = handler()
                instance = HandlerClass.create(
                    hubName     = 'hubname'
                    hubNotifier = 
                        $raw: ->
                        use: (opts, fn) => if opts.first then @inbound = fn

                    @hubContext  = 
                        clients: 
                            SOCKET_ID: 
                                title:   'client notifier name'
                                context: 
                                    hostname: 'host.name'
                                    pid:      1111
                                connection:
                                    state:   'connected'
                                    stateAt: '1'
                )

            
            it 'attaches cllent object onto traversal', (done) -> 

                raw     = 
                    _socket_id: 'SOCKET_ID'
                    uuid: 'UUID'
                context = {}
                @inbound (->), raw, context

                context.origin.should.eql 

                    title:   'client notifier name'
                    context: 
                        hostname: 'host.name'
                        pid:      1111
                    connection:
                        state:   'connected'
                        stateAt: '1'

                done()


    context 'accept', -> 

        it 'assign clientbound notification emitters according to config.client.capsule', (done) -> 

            Handler = handler
                client: 
                    capsule: 
                        hup: {}

            instance = Handler.create(
                hubName = 'hubName'
                hubNotifier = 
                    $control: -> 
                    use: ->
                hubContext  = 
                    clients: {}
                    name2id: {}
            )

            socket = id: 'SOCKET_ID', emit: ->
            client = {}
            clientContext = {}
            instance.accept 'start', socket, client, 'client title', clientContext


            socket.emit = (event, header, control, payload) -> 

                event.should.equal 'capsule'
                header.should.eql [1]
                control.should.eql 
                    type: 'hup'
                    protected: { _type: 1 }
                    hidden: { _type: 1 } 
                payload.should.eql
                    _type: 'hup'
                    hup: 1

                done()

            client.hup 1


    context 'disconnect', -> 

        before -> @HandlerClass = handler()

        beforeEach ->

            @instance = @HandlerClass.create(
                
                hubName      = 'hubname'
                @hubNotifier = 
                    $control: -> 
                    use: ->
                @hubContext  = 
                    clients: 
                        SOCKET_ID: 
                            connection:
                                state:   'connected'
                                stateAt: '1'

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

            connection = @hubContext.clients.SOCKET_ID.connection
            connection.should.eql 
                state: 'disconnected'
                stateAt: 2
            done()

    context 'capsule', -> 

        before -> @HandlerClass = handler()
        beforeEach ->

            @instance = @HandlerClass.create(

                hubName      = 'hubname'
                @hubNotifier = 
                    $control: -> 
                    $raw: (@capsule) => 
                    use: ->

                @hubContext  = 
                    clients: {}
                    name2id: {}
                opts = {}
                    
            )

        it 'naks the capsule on unsupported protocol version', (done) -> 

            handle = @instance.capsule 
                id: 'SOCKET_ID'
                emit: (event, args...) -> 

                    event.should.equal 'nak'
                    args.should.eql [
                        { uuid: 'UUID', reason: 'protocol mismatch', support: [1] }
                    ]
                    done()

            handle( 
                header   = [2]
                control  = uuid: 'UUID'
                payload  = {}
            )


        it 'acks the capsule on supported protocol version', (done) -> 

            handle = @instance.capsule 
                id: 'SOCKET_ID'
                emit: (event, args...) -> 

                    event.should.equal 'ack'
                    args.should.eql [
                        { uuid: 'UUID' }
                    ]
                    done()

            handle( 
                header   = [1]
                control  = uuid: 'UUID'
                payload  = {}
            )

        it 'reassembles the inbound payload into a capusle for the hubside middleware traversal', (done) -> 

            handle = @instance.capsule 
                id: 'SOCKET_ID'
                emit: ->
            
            handle( 
                header   = [1]
                control  = 
                    uuid:      'UUID'
                    hidden:    hiddenKey:    1
                    protected: protectedKey: 1
                payload  = 
                    key:          'value'
                    hiddenKey:    'hValue'
                    protectedKey: 'pValue'
            )

            @capsule.$uuid       .should.equal 'UUID'
            @capsule.key         .should.equal 'value'
            @capsule.hiddenKey   .should.equal 'hValue' 
            @capsule.protectedKey = 'kfdlkmsdfdsfqoknojk'
            @capsule.protectedKey.should.equal 'pValue'
            done() 


        it """loads the _socket_id onto the capsule for the first middleware 
              to assign the client objecj from the collection onto the traversal object""", (done) -> 

            handle = @instance.capsule 
                id: 'SOCKET_ID'
                emit: ->

            handle( 
                header   = [1]
                control  = 
                    uuid:      'UUID'
                    hidden:    {}
                    protected: {}
                payload  = {}
            )

            @capsule._socket_id.should.equal 'SOCKET_ID'
            done()


    context 'handshake', -> 

        before -> @HandlerClass = handler()

        beforeEach ->

            @instance = @HandlerClass.create(

                hubName      = 'hubname'
                @hubNotifier = 
                    $control: -> 
                    use: ->
                @hubContext  = 
                    clients: {}
                    name2id: {}
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
            connection = @hubContext.clients.SOCKET_ID.connection
            connection.should.eql 
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


        context 'when the originName was connected before', (done) ->

            it 'keeps the old context but refreshes from new', (done) -> 

                @hubContext.clients.OLD_SOCKET_ID = 
                    connection: {}
                    context:   
                        accumulated: 'STUFF from BEFORE'
                        willRefresh: 'this'

                @hubContext.name2id['origin title'] = 'OLD_SOCKET_ID'

                handle = @instance.handshake 
                    id: 'SOCKET_ID'
                    emit: -> 
                    disconnect: ->

                handle 'origin title', 'secret', context = 
                    hostname:    'new.host.name'
                    pid:         'new pid'
                    willRefresh: 'new this'

                
                should.not.exist @hubContext.clients.OLD_SOCKET_ID
                updatedContext = @hubContext.clients.SOCKET_ID.context
                
                updatedContext.should.eql
                    accumulated: 'STUFF from BEFORE'
                    hostname: 'new.host.name'
                    pid: 'new pid'
                    willRefresh: 'new this'

                @hubContext.name2id['origin title'].should.not.equal 'OLD_SOCKET_ID'
                @hubContext.name2id['origin title'].should.equal 'SOCKET_ID'

                done()


    context 'resume', -> 

        before -> @HandlerClass = handler()

        beforeEach ->

            @instance = @HandlerClass.create(

                hubName      = 'hubname'
                @hubNotifier = 
                    $control: ->
                    use: ->
                @hubContext  = 
                    clients: {}
                    name2id: {}
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


        it 'calls reject on wrong secret', (done) -> 

            @instance.reject = -> done()
            handle = @instance.resume 
                id: 'SOCKET_ID'
                emit: -> 
                disconnect: ->

            handle 'origin name', 'wrong secret', 'origin context'


