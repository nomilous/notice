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
                    '1': serialize: (detail) -> 'HUB 1 RECORD detail:' + detail
                    '2': serialize: (detail) -> 'HUB 2 RECORD detail:' + detail

        beforeEach -> 
            @writeHead = -> 
            @write = -> 



        it 'responds with 404 incase of no route', (done) -> 


            @mockRequest.url = '/no/such/route'
            @writeHead = (statusCode) ->
                statusCode.should.equal 404
                done()

            _manager().requestHandler @mockRequest, @mockResponse




        it 'responds with /about in 404 body', (done) -> 

            @write = (body) -> 

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


                    done()

            @mockRequest.url = '/no/such/route'
            _manager().requestHandler @mockRequest, @mockResponse


        it 'responds to /about with 200', (done) -> 

            @writeHead = (statusCode) ->
                statusCode.should.equal 200
                done()


            @mockRequest.url = '/about'
            _manager().requestHandler @mockRequest, @mockResponse


        it 'responds to /v1/hubs with an array of records for each hub', (done) -> 

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


        it 'responds to /v1/hubs/:uuid: with specific hub record', (done) -> 

            @write = (body) ->
                JSON.parse( body ).should.eql 
                    records: [
                        'HUB 1 RECORD detail:2'
                    ]
                done()

            @mockRequest.url = '/v1/hubs/1'
            _manager().requestHandler @mockRequest, @mockResponse








