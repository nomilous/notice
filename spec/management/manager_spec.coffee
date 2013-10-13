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
            @mockRequest = {}
            Object.defineProperty @mockRequest, 'headers', 
                get: => @headers

            @writeHead = ->
            @write = ->
            @mockResponse = end: ->
            Object.defineProperty @mockResponse, 'writeHead', 
                get: => => @writeHead.apply null, arguments
            Object.defineProperty @mockResponse, 'write', 
                get: => => @write.apply null, arguments

            m = manager manager: 
                authenticate: 
                    username: 'username'
                    password: 'password'
                listen: port: 3210

            m.register 
                hubs: 
                    'hub name 1': {}
                    'hub name 2': {}

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
                        '/v1/hubs':
                            description: 'list present hub records'

                    done()

            @mockRequest.url = '/no/such/route'
            _manager().requestHandler @mockRequest, @mockResponse


        it 'responds to /about with 200', (done) -> 

            @writeHead = (statusCode) ->
                statusCode.should.equal 200
                done()


            @mockRequest.url = '/about'
            _manager().requestHandler @mockRequest, @mockResponse


        it 'responds to /v1/hubs with a array of records for each hub', (done) -> 

            @write = (body) ->
                JSON.parse( body ).should.eql 
                    records: [
                        {title: 'hub name 1'}
                        {title: 'hub name 2'}
                    ]
                done()


            @mockRequest.url = '/v1/hubs'
            _manager().requestHandler @mockRequest, @mockResponse










