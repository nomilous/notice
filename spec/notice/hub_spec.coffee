should      = require 'should'
{parallel}  = require 'also'
{hub,_hub}  = require '../../lib/notice/hub'
{_notifier} = require '../../lib/notice/notifier'
Listener    = require '../../lib/notice/listener'

describe 'hub', -> 

    beforeEach -> 
        @now = Date.now
        Listener.listen = (opts, callback) -> 
            callback()
            on: ->

    afterEach -> 
        Date.now = @now


    context 'factory', ->

        it 'creates a Hub definition', (done) -> 

            Hub = hub()
            Hub.create.should.be.an.instanceof Function
            done()


    context 'create()', -> 

        it 'requires hubName', (done) -> 

            Hub = hub()
            Hub.create undefined, {}, (error) -> 

                error.should.match /requires hubName as string/
                done()


        it 'calls back with a hub instance', (done) -> 

            Hub = hub()
            Hub.create 'hub name', {}, (error, hub) -> 

                _hub().hubs['hub name'].should.equal hub
                done()

        it 'resolves with the new hub as notifier instance', (done) -> 

            Hub = hub()
            Hub.create( 'hub name' ).then (hub) -> 

                hub.should.equal _notifier().notifiers['hub name']
                _hub().hubs['hub name'].should.equal hub
                done()

        it 'can create multiple hubs in parallel', (done) -> 

            Hub = hub()
            parallel([
                -> Hub.create 'hub1'
                -> Hub.create 'hub2'
                -> Hub.create 'hub3'
            ])
            .then ([hub1, hub2, hub3]) ->
                
                _hub().hubs['hub1'].should.equal hub1
                _hub().hubs['hub2'].should.equal hub2
                _hub().hubs['hub3'].should.equal hub3
                done()

        it 'errors on create with duplicate name', (done) -> 

            Hub = hub()
            parallel([
                -> Hub.create 'hub1'
                -> Hub.create 'hub1'
            ])
            .then (->), (error) -> 

                error.should.match /is already defined/
                done()

        it 'calls listen with opts.listen', (done) -> 

            Listener.listen = (opts, callback) -> 
                opts.should.eql 
                    loglevel: 'LOGLEVEL'
                    address: 'ADDRESS'
                    port: 'PORT'
                    cert: 'CERT'
                    key: 'KEY'
                done()
                on: ->

            Hub = hub()
            Hub.create 'hub1', 
                listen: 
                    loglevel: 'LOGLEVEL'
                    address:  'ADDRESS'
                    port:     'PORT'
                    cert:     'CERT'
                    key:      'KEY'

        it 'attaches reference to the listening address onto the hub', (done) -> 

            Listener.listen = (opts, callback) -> 
                callback null, 'ADDRESS'
                on: ->

            Hub = hub()
            Hub.create 'hub1', {}, (err, hub) -> 

                hub.listening.should.equal 'ADDRESS'
                done()



        context 'on connection', -> 

            beforeEach -> 
                @whenEvent = {}
                Listener.listen = (opts, callback) => 
                    callback null, 'ADDRESS'
                    on: (event, handler) => 
                        if @whenEvent[event]? then handler @whenEvent[event]


            context 'when handshake', -> 

                it 'verifies the secret and disconnects on bad match', (done) -> 

                    @whenEvent['connection'] = 
                        
                        #
                        # configure a mock socket with which to fire the 
                        # connection event
                        # 
                        
                        on: (event, listener) -> 

                            #
                            # emit mock handshake event as if a remote client sent it
                            #

                            if event == 'handshake' 
                                listener 'originName', 'wrongsecret', 'CONTEXT'

                        disconnect: -> done()

                    Hub = hub()
                    Hub.create 'hub1', listen: secret: 'rightsecret'


                it 'adds the client to the collection on handshake success', (done) -> 

                    @whenEvent['connection'] = 
                        id: 'SOCKET_ID'
                        on: (event, listener) -> 
                            if event == 'handshake' 
                                listener 'originName', 'rightsecret', 'CONTEXT'
                        emit: ->

                    Hub = hub()
                    Hub.create 'hub1', listen: secret: 'rightsecret'
                    _hub().clients.SOCKET_ID.title.should.equal 'originName'
                    _hub().clients.SOCKET_ID.context.should.equal 'CONTEXT'
                    _hub().clients.SOCKET_ID.hub.should.equal 'hub1'
                    done()


                #
                # difficult to test...
                #
                # it.only 'does not allow more than on connection with same originName', (done) ->

                #     count = 0
                #     @whenEvent['connection'] = 
                        
                #         on: (event, listener) -> 
                #             if event == 'handshake' 
                #                 listener 'originName', 'rightsecret', 'CONTEXT'
                #                 process.nextTick -> listener 'originName', 'rightsecret', 'CONTEXT'
                #         emit: (event, args...) ->
                #             console.log arguments

                #     Object.defineProperty @whenEvent['connection'], 'id',
                #         get: -> count++

                #     Hub = hub()
                #     Hub.create 'hub1', listen: secret: 'rightsecret'



                it 'sets the connection.state to connected', (done) -> 

                    Date.now = -> 1
                    @whenEvent['connection'] = 
                        id: 'SOCKET_ID'
                        on: (event, listener) -> 
                            if event == 'handshake' 
                                listener 'originName', 'rightsecret', 'CONTEXT'
                        emit: ->

                    Hub = hub()
                    Hub.create 'hub1', listen: secret: 'rightsecret'

                    connected = _hub().clients.SOCKET_ID.connected
                    connected.should.eql
                        state: 'connected'
                        stateAt: 1
                    done()


                it 'creates an entry in the name2id index', (done) -> 

                    @whenEvent['connection'] = 
                        id: 'SOCKET_ID'
                        on: (event, listener) -> 
                            if event == 'handshake' 
                                listener 'originName', 'rightsecret', 'CONTEXT'
                        emit: ->

                    Hub = hub()
                    Hub.create 'hub1', listen: secret: 'rightsecret'
                    name2id = _hub().name2id
                    name2id.should.eql
                        originName: 'SOCKET_ID'
                    done()


                it 'remove or transfer previous reference to this client if present'
                    # 
                    # for when client does not disconnect cleanly and 
                    # and housekeeper has not yet reaped the reference
                    # 


                it 'accept includes hub context'
                it 'sends accept to client on handshake success', (done) -> 

                    @whenEvent['connection'] = 
                        id: 'SOCKET_ID'
                        on: (event, listener) -> 
                            if event == 'handshake' 
                                listener 'originName', 'rightsecret', 'CONTEXT'
                        emit: (event, args...) -> 
                            if event == 'accept' then done()

                    Hub = hub()
                    Hub.create 'hub1', listen: secret: 'rightsecret'


            context 'when resume', -> 

                it 'is the same as connect for now'


        context 'on disconnect', -> 

            beforeEach -> 
                @whenEvent = {}
                Listener.listen = (opts, callback) => 
                    callback null, 'ADDRESS'
                    on: (event, handler) => 
                        console.log event
                        if @whenEvent[event]? then handler @whenEvent[event]
                    emit: ->


                

            it 'marks the client reference as disconnected', (done) -> 

                Date.now = -> 1
                @whenEvent['connection'] = 
                    id: 'SOCKET_ID'
                    on: (event, listener) -> 
                        if event == 'handshake' 
                            listener 'originName', 'rightsecret', 'CONTEXT'
                        if event == 'disconnect' 
                            listener()
                    emit: ->

                
                
                Hub = hub()
                Hub.create 'hub1', listen: secret: 'rightsecret'

                connected = _hub().clients.SOCKET_ID.connected
                connected.should.eql
                    state: 'disconnected'
                    stateAt: 1
                done()



            it 'reaps the client reference after configurable period'
        

            


return
io = require 'socket.io'

# require('nez').realize 'Hub', (Hub, test, context, should, http, Notifier) -> 

should   = require 'should'
Hub      = require '../../lib/notice/hub'
http     = require 'http'
Notifier = require '../../lib/notice/notifier'

describe 'Hub', ->

    context 'create()', -> 

        it 'is an exported function', (done) -> 

            Hub.create.should.be.an.instanceof Function
            done()

        it 'requires a name', (done) -> 

            try Hub.create()
            catch error
                error.should.match /requires hubName as string/
                done()

    
    context 'hubside pipeline', -> 

        it 'is created', (done) -> 

            spy = Notifier.create
            Notifier.create = (title) -> 
                Notifier.create = spy
                title.should.equal 'title'
                throw 'go no futher'

            try Hub.create 'title'
            catch error

                error.should.match /go no futher/
                done()


    context 'listening', -> 

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

            #
            # mock connect immediately
            #

            callback SOCKET


        it 'calls back with the hubside inbound notifier', (done) -> 

            NOTIFIER = 
                use: -> 'moo'

            spy = Notifier.create
            Notifier.create = (title) -> 
                Notifier.create = spy
                NOTIFIER

            Hub.create 'name', listen: secret: 'SECRET', (error, notice) -> 

                notice.use().should.equal 'moo'
                done()


        context 'on connected socket', -> 


            it 'attaches ref to the listening address', (done) ->

                opts = listen: secret: 'SECRET'

                Hub.create 'name', opts, (error, notice) -> 

                    opts.listening.should.eql 
                        transport: 'http'
                        address: 'ADDRESS'
                        port: 'PORT'

                    done()


            it 'sends accept if the secret matches', (done) -> 

                SENT.events = []
                Hub.create 'name', listen: secret: 'SECRET', -> 

                    SENT.events[0].should.eql '0': 'accept'
                    done()


            it 'creates a response pipeline on the first connect', (done) -> 

                NOTIFIERS = {}
                spy = Notifier.create
                Notifier.create = (title) -> 
                    NOTIFIERS[title] = 1
                    use: ->

                Hub.create 'hub name', listen: secret: 'SECRET', -> 

                    Notifier.create = spy
                    NOTIFIERS['hub name'].should.equal 1
                    done()


            it 'feeds received messages into the pipeline', (done) -> 

                spy = Notifier.create
                Notifier.create = (title) -> 
                    Notifier.create = spy
                    use: ->

                    #
                    # spy on notice.info.normal()
                    #
                    info: normal: -> 
                        done()


                SOCKET.on = (event, callback) -> 
                    if event == 'handshake' 
                        callback 'SECRET', REMOTE: 'CONTEXT'

                    #
                    # respond to info subscription with 
                    # mock inbound info message
                    #
                    if event == 'info' then callback
                        title: 'TITLE'
                        tenor: 'normal'
                        {}

                Hub.create 'name', listen: secret: 'SECRET', -> 

