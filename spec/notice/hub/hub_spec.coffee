should      = require 'should'
{parallel}  = require 'also'
{hub, _hub, listener} = require '../../../lib/notice/hub'
{_Handler, _handler}  = require '../../../lib/notice/hub/hub_handler'
{_manager}    = require '../../../lib/api/manager'
{_ticker} = require '../../../lib/api/ticker'
{_notifier} = require '../../../lib/notice/notifier'


describe 'hub', -> 

    beforeEach -> 
        listener.listen = (opts, callback) -> 
            callback null, 'ADDRESS_HASH'
            on: ->


    context 'factory', ->

        it 'creates a Hub definition', (done) -> 

            Hub = hub()
            Hub.create.should.be.an.instanceof Function
            done()


        it 'starts a api if configured and shares it on the definition config', (done) -> 

            config =
                api: 
                    authenticate: {}
                    listen: port: 33333
            hub config
            should.exist config.running.api
            should.exist _manager().register
            should.exist _manager().routes
            done()


    context 'create()', -> 

        it 'requires hubName', (done) -> 

            Hub = hub()
            Hub.create undefined, {}, (error) -> 

                error.should.match /requires arg hubName/
                done()

        it 'falls back to opts.title if no hubName', (done) -> 

            Hub = hub()
            Hub.create title: 'Title', uuid: 1
            should.exist _hub().hubs[1]
            done()

        it 'generates a uuid for the notifier', (done) -> 

            Hub = hub()
            Hub.create title: 'Title'

            should.exist uuid for uuid of _hub().hubs
            done()


        it 'uses a provided uuid for the notifier', (done) -> 

            Hub = hub()
            Hub.create title: 'Title', uuid: 1
            _hub().hubs[1].uuid.should.equal 1
            done()


        it 'calls back with a hub instance', (done) -> 

            Hub = hub()
            Hub.create 'hub name', uuid: 1, (error, hub) -> 

                _hub().hubs[1].should.equal hub
                done()

        it 'resolves with the new hub as notifier instance', (done) -> 

            Hub = hub()
            Hub.create( 'hub name', uuid: 1).then (hub) -> 

                hub.should.equal _notifier().notifiers['hub name']
                _hub().hubs[1].should.equal hub
                done()

        it 'provides a hub cache for userdefined usage', (done) -> 

            Hub = hub()
            Hub.create( 'hub name' ).then (hub) -> 

                should.exist hub.cache
                done()

        it 'config can assign the initial cache object', (done) -> 

            Hub = hub()
            Hub.create
                title: 'hubname'
                cache: thing: 1
                (err, hub) -> 

                    hub.cache.thing.should.equal 1
                    done()

        it 'can create multiple hubs in parallel', (done) -> 

            Hub = hub()
            parallel([
                -> Hub.create 'hub1', uuid: 1
                -> Hub.create 'hub2', uuid: 2
                -> Hub.create 'hub3', uuid: 3
            ])
            .then ([hub1, hub2, hub3]) ->
                
                _hub().hubs[1].should.equal hub1
                _hub().hubs[2].should.equal hub2
                _hub().hubs[3].should.equal hub3
                done()

        it 'errors on create with duplicate name', (done) -> 

            Hub = hub()
            parallel([
                -> Hub.create 'hub1'
                -> Hub.create 'hub1'
            ])
            .then (->), (error) -> 

                #console.log error
                error.should.match /is already defined/
                done()

        it 'calls listen with opts.listen', (done) -> 

            listener.listen = (opts, callback) -> 
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

            listener.listen = (opts, callback) -> 
                callback null, 'ADDRESS'
                on: ->

            Hub = hub()
            Hub.create 'hub1', {}, (err, hub) -> 

                hub.listening.should.equal 'ADDRESS'
                done()


        context 'ticks', ->

            it 'hub.create creates a ticker', (done) -> 

                
                Hub = hub()
                Hub.create 'hub1', {}, (err, hub) -> 

                should.exist _ticker().timers.hub1
                done()




        context 'listening.on', -> 

            beforeEach -> 
                @handler = {}
                @whenEvent = {}
                listener.listen = (opts, callback) => 
                    callback null, 'ADDRESS'
                    on: (event, handler) => 

                        #
                        # store each registering hander as the 
                        # hub comes ""online""
                        #

                        @handler[event] = handler


            it 'on connection assigns handler.handshake to handle handshake', (done) -> 

                Hub = hub()
                Hub.create 'hub1', listen: secret: 'rightsecret'
                _handler().handshake = (socket) -> 

                    #
                    # was the handler called to return a handshake hander
                    # function for this connecting socket
                    #

                    socket.id.should.equal 'SOCKET_ID'  
                    return handshakeHandler = -> 'HANDSHAKE HANDLER'

                #
                # fire the connection handler with a mock socket
                #

                @handler['connection']
                    id: 'SOCKET_ID'
                    on: (event, handler) -> 
                        if event == 'handshake' 
                            handler().should.equal 'HANDSHAKE HANDLER'
                            done()


            it 'on connection assigns handler.resume to handle resume', (done) -> 

                Hub = hub()
                Hub.create 'hub1', listen: secret: 'rightsecret'
                _handler().resume = (socket) -> 
                    socket.id.should.equal 'SOCKET_ID'  
                    -> 'RESUME HANDLER'

                @handler['connection']
                    id: 'SOCKET_ID'
                    on: (event, handler) -> 
                        if event == 'resume' 
                            handler().should.equal 'RESUME HANDLER'
                            done()

            it 'on connection assigns handler.disconnect to handle disconnect', (done) -> 

                Hub = hub()
                Hub.create 'hub1', listen: secret: 'rightsecret'
                _handler().disconnect = (socket) -> 
                    socket.id.should.equal 'SOCKET_ID'  
                    -> 'DISCONNECT HANDLER'

                @handler['connection']
                    id: 'SOCKET_ID'
                    on: (event, handler) -> 
                        if event == 'disconnect' 
                            handler().should.equal 'DISCONNECT HANDLER'
                            done()

            it 'on connection assigns handler.capsule to handle capsule', (done) -> 

                Hub = hub()
                Hub.create 'hub1', listen: secret: 'rightsecret'
                _handler().capsule = (socket) -> 
                    socket.id.should.equal 'SOCKET_ID'  
                    -> 'CAPSULE HANDLER'

                @handler['connection']
                    id: 'SOCKET_ID'
                    on: (event, handler) -> 
                        if event == 'capsule' 
                            handler().should.equal 'CAPSULE HANDLER'
                            done()


            it 'reaps the client reference after configurable period' 

