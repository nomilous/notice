http    = require 'http'
https   = require 'https'
should  = require 'should'
{manager,_manager} = require '../../lib/management/manager'


describe 'manage', ->

    beforeEach -> 
        @createHttp = http.createServer
        @createHttps = https.createServer

    afterEach -> 
        http.createServer = @createHttp
        https.createServer = @createHttps


    it 'throws on missing config.manage.listen', (done) -> 

        try manager {}
        catch error
            done()

    it 'throws on missing port', (done) -> 

        try manager manager: listen: {}, authenticate: {}
        catch error
            error.should.match /manager requires opt config.manager.listen.port/
            done()

    it 'creates an http server', (done) -> 

        http.createServer = -> done(); listen: ->
        manager manager: 
            authenticate: {}
            listen: port: 3210


    xit 'creates an https server if cert and key are configured', (done) -> 

        # 
        # dunnot why this isnt stubbing
        # 

        https.createServer = -> done(); listen: ->
        manager manager: 
            authenticate: {}
            listen:
                port: 3210
                cert: 'cert'
                key:  'key'

    context 'routes', -> 


        before -> 

            @headers = authorization: 'Basic ' + new Buffer('username:password', 'utf8').toString 'base64'
            @mockRequest = method: 'GET'
            Object.defineProperty @mockRequest, 'headers', 
                get: => @headers

            @writeHead = ->
            @write = ->
            @mockResponse = end: ->
            Object.defineProperty @mockResponse, 'writeHead', 
                get: => => try @writeHead.apply null, arguments
            Object.defineProperty @mockResponse, 'write', 
                get: => => try @write.apply null, arguments

            @serialize1 = (detail) ->
            @serialize2 = (detail) ->
            m = manager manager: 
                authenticate: 
                    username: 'username'
                    password: 'password'
                listen: port: 3210

            m.register 
                hubs: 
                    'hub name 1': uuid: 1
                    'hub name 2': uuid: 2
                uuids:
                    '1': serialize: (detail) => try @serialize1.apply null, arguments
                    '2': serialize: (detail) => try @serialize2.apply null, arguments

        beforeEach -> 
            @writeHead = -> 
            @write = -> 
            @serialize1 = (detail) -> 'HUB 1 RECORD detail:' + detail
            @serialize2 = (detail) -> 'HUB 2 RECORD detail:' + detail



        it 'responds with 404 incase of no route', (done) -> 


            @mockRequest.url = '/no/such/route'
            @writeHead = (statusCode) ->
                statusCode.should.equal 404
                done()

            _manager().requestHandler @mockRequest, @mockResponse




        it 'responds to /about', (done) -> 

            @write = (body) -> 

                #console.log body

                JSON.parse( body ).should.eql 

                    module:  'notice'
                    version: '0.0.11'
                    doc:     'https://github.com/nomilous/notice/tree/develop/spec/management'
                    endpoints: 
                        '/about': 
                            description: 'show this'
                            methods: ['GET']
                        '/v1/hubs':
                            description: 'list present hubs'
                            methods: ['GET']
                        '/v1/hubs/:uuid:':
                            description: 'get a hub'
                            methods: ['GET']
                        '/v1/hubs/:uuid:/metrics':
                            description: 'get only the metrics'
                            methods: ['GET']
                        '/v1/hubs/:uuid:/errors':
                            description: 'get only the recent errors'
                            methods: ['GET']
                        '/v1/hubs/:uuid:/middlewares':
                            description: 'get only the middlewares'
                            methods: ['GET']
                        '/v1/hubs/:uuid:/middlewares/:id:':
                            description: 'get or update or delete a middleware'
                            methods: ['GET', 'POST', 'DELETE']
                            accepts: ['text/javascript', 'text/coffee-script']

                done()

            @mockRequest.url = '/about'
            _manager().requestHandler @mockRequest, @mockResponse


        it 'responds to GET /about with 200', (done) -> 

            @writeHead = (statusCode) ->
                statusCode.should.equal 200
                done()


            @mockRequest.url = '/about'
            _manager().requestHandler @mockRequest, @mockResponse


        it 'responds to GET /v1/hubs with an array of records for each hub', (done) -> 

            @write = (body) ->
                JSON.parse( body ).should.eql 
                    records: [
                        'HUB 1 RECORD detail:1'
                        'HUB 2 RECORD detail:1'
                    ]
                done()


            @mockRequest.url = '/v1/hubs'
            _manager().requestHandler @mockRequest, @mockResponse


        it 'respods 404 to no such /v1/hubs/:uuid:', (done) -> 

            @writeHead = (statusCode) ->
                statusCode.should.equal 404
                done()


            @mockRequest.url = '/v1/hubs/3'
            _manager().requestHandler @mockRequest, @mockResponse


        it 'responds to GET /v1/hubs/:uuid: with specific hub record', (done) -> 

            @write = (body) ->
                JSON.parse( body ).should.equal 'HUB 1 RECORD detail:2'

                done()

            @mockRequest.url = '/v1/hubs/1'
            _manager().requestHandler @mockRequest, @mockResponse


        it 'responds to GET /v1/hubs/:uuid:/metrics', (done) -> 

            @write = (body) -> 
                JSON.parse( body ).should.eql records: ['METRICS']
                done()

            @serialize1 = -> metrics: 'METRICS'
            @mockRequest.url = '/v1/hubs/1/metrics'
            _manager().requestHandler @mockRequest, @mockResponse


        it 'responds to GET /v1/hubs/:uuid:/errors', (done) -> 

            @write = (body) -> 
                JSON.parse( body ).should.eql records: ['ERRORS']
                done()

            @serialize1 = -> errors: 'ERRORS'
            @mockRequest.url = '/v1/hubs/1/errors'
            _manager().requestHandler @mockRequest, @mockResponse


        it 'responds to GET /v1/hubs/:uuid:/middlewares', (done) -> 

            @write = (body) -> 
                JSON.parse( body ).should.eql records: 'MIDDLEWARES'
                done()

            @serialize1 = -> middlewares: 'MIDDLEWARES'
            @mockRequest.url = '/v1/hubs/1/middlewares'
            _manager().requestHandler @mockRequest, @mockResponse


        it 'responds to GET /v1/hubs/:uuid:/middlewares/:id:', (done) -> 

            @write = (body) -> 
                console.log body
                JSON.parse( body ).should.eql 
                    title: 'title'
                    id:  'title'
                    metrics: []
                    
                done()

            @serialize1 = -> middlewares: [
                title: 'title'
                id:  'title'
                metrics: []
            ]
            @mockRequest.url = '/v1/hubs/1/middlewares/title'
            _manager().requestHandler @mockRequest, @mockResponse



        context 'POST /v1/hubs/:uuid:/middlewares/:title:', ->

            # as text/javascript or text/coffee-script 
        context 'DELETE /v1/hubs/:uuid:/middlewares/:title:', ->


        context 'POST /vi/hubs/:uuid:/configure', -> 

            it 'modifies introspection level'
            it 'and possibly other things'

        context 'GET /v1/hubs/:uuid:/reset', -> 

            it 'zeroes all metric counters'




