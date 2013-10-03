should     = require 'should'
{parallel} = require 'also'
{hub,_hub} = require '../../lib/notice/hub'

describe 'hub', -> 

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

        it 'resolves with the new hub', (done) -> 

            Hub = hub()
            Hub.create( 'hub name' ).then (hub) -> 

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

