http       = require 'http'
https      = require 'https'
should     = require 'should'
{parallel} = require 'also'
{Client}   = require 'dinkum'
# {_notifier,notifier} = require '../../lib/notice/notifier'
{hub,_hub}         = require '../../lib/notice/hub/hub'
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

        hub1 = undefined
        hub2 = undefined
        client = undefined

        before (done) -> 

            Hub = hub

                manager:
                    listen: port: 40404
                    authenticate: 
                        username: 'user'
                        password: 'pass'

            parallel([
                
                -> Hub.create title: 'Hub One', uuid: 1
                -> Hub.create title: 'Hub Two', uuid: 2

            ]).then(
                (hubs) -> 
                    hub1 = hubs[0]
                    hub2 = hubs[1]

                    client = Client.create
                        transport: 'http'
                        port: 40404
                        authenticator:
                            module: 'basic_auth'
                            username: 'user'
                            password: 'pass'

                    done()

                (error) -> console.log SPEC_ERROR: error, filename: __filename
            )


        it 'has two hubs and a client to test with', -> 

            should.exist hub1
            should.exist hub2
            should.exist client


        it 'responds with 404 incase of no route', (done) -> 

            client.get 
                path: '/no/route' 

            .then ({statusCode}) -> 
                statusCode.should.equal 404
                done()


        it 'responds to /about', (done) -> 

            client.get 
                path: '/about' 

            .then ({statusCode, body}) -> 

                statusCode.should.equal 200

                body.should.eql {

                  "module": "notice",
                  "version": "0.0.12",
                  "doc": "https://github.com/nomilous/notice/tree/master/spec/management",
                  "endpoints": {
                    "/about": {
                      "description": "show this",
                      "methods": [
                        "GET"
                      ]
                    },
                    "/v1/hubs": {
                      "description": "list present hubs",
                      "methods": [
                        "GET"
                      ]
                    },
                    "/v1/hubs/:uuid:": {
                      "description": "get a hub",
                      "methods": [
                        "GET"
                      ]
                    },
                    "/v1/hubs/:uuid:/stats": {
                      "description": "get only the hub stats",
                      "methods": [
                        "GET"
                      ]
                    },
                    "/v1/hubs/:uuid:/errors": {
                      "description": "get only the recent errors",
                      "methods": [
                        "GET"
                      ]
                    },
                    "/v1/hubs/:uuid:/cache": {
                      "description": "get output from a serailization of the traversal",
                      "methods": [
                        "GET"
                      ]
                    },
                    "/v1/hubs/:uuid:/cache/**/*": {
                      "description": "get nested subkey from the cache tree",
                      "methods": [
                        "GET"
                      ]
                    },
                    "/v1/hubs/:uuid:/tools": {
                      "description": "get output from a serailization of the tools tree",
                      "methods": [
                        "GET"
                      ]
                    },
                    "/v1/hubs/:uuid:/tools/**/*": {
                      "description": "get nested subkey from the tools key",
                      "methods": [
                        "GET"
                      ]
                    },
                    "/v1/hubs/:uuid:/clients": {
                      "description": "pending",
                      "methods": [
                        "GET"
                      ]
                    },
                    "/v1/hubs/:uuid:/middlewares": {
                      "description": "get only the middlewares",
                      "methods": [
                        "GET"
                      ]
                    },
                    "/v1/hubs/:uuid:/middlewares/:title:": {
                      "description": "get or update or delete a middleware",
                      "methods": [
                        "GET"
                      ]
                    },
                    "/v1/hubs/:uuid:/middlewares/:title:/disable": {
                      "description": "disable a middleware",
                      "methods": [
                        "GET"
                      ]
                    },
                    "/v1/hubs/:uuid:/middlewares/:title:/enable": {
                      "description": "enable a middleware",
                      "methods": [
                        "GET"
                      ]
                    },
                    "/v1/hubs/:uuid:/middlewares/:title:/replace": {
                      "description": "replace a middleware",
                      "methods": [
                        "POST"
                      ],
                      "accepts": [
                        "text/javascript",
                        "text/coffeescript"
                      ]
                    }
                  }
                }
                done()


        it 'responds to GET /v1/hubs with an array of records for each hub', (done) -> 

            client.get 
                path: '/v1/hubs' 

            .then ({statusCode, body}) -> 

                console.log JSON.stringify arguments, null, 2




        # before -> 

        #     @headers = authorization: 'Basic ' + new Buffer('username:password', 'utf8').toString 'base64'
        #     @mockRequest = method: 'GET'
        #     Object.defineProperty @mockRequest, 'headers', 
        #         get: => @headers

        #     @mockRequest.on = (event, listener) => 
        #         if event == 'end' then listener()
        #         if event == 'data' then listener @mockRequest.body

        #     @writeHead = ->
        #     @write = ->
        #     @mockResponse = end: ->
        #     Object.defineProperty @mockResponse, 'writeHead', 
        #         get: => => try @writeHead.apply null, arguments
        #     Object.defineProperty @mockResponse, 'write', 
        #         get: => => try @write.apply null, arguments

        #     @serializeHub1 = (detail) ->
        #     @serializeHub2 = (detail) ->
        #     m = manager manager: 
        #         authenticate: 
        #             username: 'username'
        #             password: 'password'
        #         listen: port: 3210

        #     m.register 
        #         hubs: 
        #             '1': 
        #                 serialize: (detail) => try @serializeHub1.apply null, arguments
        #                 #got: => @got.apply null, arguments
        #                 #force: => @force.apply null, arguments
        #             '2': 
        #                 uuid: 2
        #                 serialize: (detail) => try @serializeHub2.apply null, arguments

        # beforeEach -> 
        #     @mockRequest.method = 'GET'
        #     @writeHead = -> 
        #     @write = -> 
        #     @serializeHub1 = (detail) -> 'HUB 1 RECORD detail:' + detail
        #     @serializeHub2 = (detail) -> 'HUB 2 RECORD detail:' + detail



        # it.only 'responds to GET /v1/hubs with an array of records for each hub', (done) -> 

        #     @write = (body) ->
        #         console.log body
        #         JSON.parse( body ).should.eql 
        #             records: [
        #                 'HUB 1 RECORD detail:1'
        #                 'HUB 2 RECORD detail:1'
        #             ]
        #         done()


        #     @mockRequest.url = '/v1/hubs'
        #     _manager().requestHandler @mockRequest, @mockResponse


        # it 'respods 404 to no such /v1/hubs/:uuid:', (done) -> 

        #     @writeHead = (statusCode) ->
        #         statusCode.should.equal 404
        #         done()


        #     @mockRequest.url = '/v1/hubs/3'
        #     _manager().requestHandler @mockRequest, @mockResponse


        # it 'responds to GET /v1/hubs/:uuid: with specific hub record', (done) -> 

        #     @write = (body) ->
        #         JSON.parse( body ).should.equal 'HUB 1 RECORD detail:2'

        #         done()

        #     @mockRequest.url = '/v1/hubs/1'
        #     _manager().requestHandler @mockRequest, @mockResponse


        # it 'responds to GET /v1/hubs/:uuid:/stats', (done) -> 

        #     @write = (body) -> 
        #         JSON.parse( body ).should.eql 'STATS'
        #         done()

        #     @serializeHub1 = -> stats: 'STATS'
        #     @mockRequest.url = '/v1/hubs/1/stats'
        #     _manager().requestHandler @mockRequest, @mockResponse


        # it 'responds to GET /v1/hubs/:uuid:/errors', (done) -> 

        #     @write = (body) -> 
        #         JSON.parse( body ).should.eql 'ERRORS'
        #         done()

        #     @serializeHub1 = -> errors: 'ERRORS'
        #     @mockRequest.url = '/v1/hubs/1/errors'
        #     _manager().requestHandler @mockRequest, @mockResponse

        # it 'responds to GET /v1/hubs/:uuid:/cache', (done) -> 

        #     @write = (body) -> 
        #         JSON.parse( body ).should.eql key: 'VALUE'
        #         done()

        #     @serializeHub1 = -> cache: key: 'VALUE'
        #     @mockRequest.url = '/v1/hubs/1/cache'
        #     _manager().requestHandler @mockRequest, @mockResponse


        # it 'responds to GET /v1/hubs/:uuid:/cache/**/* to arbitrary depth', (done) -> 

        #     @write = (body) -> 
        #         body.should.equal '"VALUE"'
        #         done()

        #     @serializeHub1 = -> cache: nested: deeper: 'VALUE'
        #     @mockRequest.url = '/v1/hubs/1/cache/nested/deeper'
        #     _manager().requestHandler @mockRequest, @mockResponse

        # xit 'responds to POST /v1/hubs/:uuid:/cache/**/* by replacing the specified key in the hash', (done) -> 

        #     @writeHead = (statusCode) -> 
        #         console.log statusCode
        #         done()

        #     @write = (body) -> 
        #         body.should.equal '"VALUE"'
        #         #done()

        #     @serializeHub1 = -> cache: nested: deeper: 'VALUE'

        #     @mockRequest.url = '/v1/hubs/1/cache/nested/deeper'
        #     @mockRequest.method = 'POST'
        #     @mockRequest.body = """

        #     ### pending

        #     """
        #     _manager().requestHandler @mockRequest, @mockResponse


        # it 'responds to GET /v1/hubs/:uuid:/tools', (done) ->

        #     @write = (body) -> 
        #         JSON.parse( body ).should.eql key: 'VALUEEE'
        #         done()

        #     @serializeHub1 = -> tools: key: 'VALUEEE'
        #     @mockRequest.url = '/v1/hubs/1/tools'
        #     _manager().requestHandler @mockRequest, @mockResponse


        # it 'responds to GET /v1/hubs/:uuid:/tools/**/*', (done) ->

        #     @write = (body) -> 
        #         JSON.parse( body ).should.eql 'VALUEEE'
        #         done()

        #     @serializeHub1 = -> tools: nested: deeper: 'VALUEEE'
        #     @mockRequest.url = '/v1/hubs/1/tools/nested/deeper'
        #     _manager().requestHandler @mockRequest, @mockResponse




        # it 'responds to GET /v1/hubs/:uuid:/clients', (done) -> 

        #     @write = (body) -> 
        #         JSON.parse( body ).should.eql key: 'VALUE'
        #         done()

        #     @serializeHub1 = -> clients: key: 'VALUE'
        #     @mockRequest.url = '/v1/hubs/1/clients'
        #     _manager().requestHandler @mockRequest, @mockResponse


        # it 'responds to GET /v1/hubs/:uuid:/middlewares', (done) -> 

        #     @write = (body) -> 
        #         JSON.parse( body ).should.eql 'MIDDLEWARES'
        #         done()

        #     @serializeHub1 = -> middlewares: 'MIDDLEWARES'
        #     @mockRequest.url = '/v1/hubs/1/middlewares'
        #     _manager().requestHandler @mockRequest, @mockResponse


        # it 'responds to GET /v1/hubs/:uuid:/middlewares/:title:', (done) -> 

        #     @write = (body) -> 
        #         #console.log body
        #         JSON.parse( body ).should.eql 
        #             enabled: true
        #             metrics: []
                    
        #         done()

        #     @serializeHub1 = -> middlewares: 
        #         title: 
        #             enabled: true
        #             metrics: []
            
        #     @mockRequest.url = '/v1/hubs/1/middlewares/title'
        #     _manager().requestHandler @mockRequest, @mockResponse


        # it 'disables middleware with GET v1/hubs/:uuid:/middlewares/:title:/disable', (done) -> 

        #     Notifier = notifier()
        #     instance = Notifier.create 'hub name', 1
        #     instance.use 
        #         title: 'title'
        #         (next) -> next()

        #     @write = (body) -> 
        #         #console.log body
        #         JSON.parse( body ).should.eql 
        #             enabled: false
        #             metrics: {}
                    
        #         done()

        #     @serializeHub1 = -> instance.serialize(2)
        #     @got        = instance.got
        #     @force      = instance.force

        #     @mockRequest.url = '/v1/hubs/1/middlewares/title/disable'
        #     _manager().requestHandler @mockRequest, @mockResponse

        # it 'returns 404 on no such middleware', (done) -> 

        #     Notifier = notifier()
        #     instance = Notifier.create 'hub name', 1
        #     @serializeHub1 = -> instance.serialize(2)
        #     @got        = instance.got

        #     @writeHead = (statusCode) ->
        #         statusCode.should.equal 404
        #         done()

        #     @mockRequest.url = '/v1/hubs/1/middlewares/nosuchmiddleware/disable'
        #     _manager().requestHandler @mockRequest, @mockResponse


        # it 'enables middleware with  GET v1/hubs/:uuid:/middlewares/:title:/enable', (done) -> 

        #     Notifier = notifier()
        #     instance = Notifier.create 'hub name', 1
        #     instance.use 
        #         title: 'title'
        #         enabled: false
        #         (next) -> next()

        #     @write = (body) -> 
        #         JSON.parse( body ).should.eql 
        #             enabled: true
        #             metrics: {}
                    
        #         done()

        #     @serializeHub1 = -> instance.serialize(2)
        #     @got        = instance.got
        #     @force      = instance.force

        #     @mockRequest.url = '/v1/hubs/1/middlewares/title/enable'
        #     _manager().requestHandler @mockRequest, @mockResponse


        # context 'POST /v1/hubs/:uuid:/middlewares/:title:/replace', -> 

        #     it 'accepts only post', (done) -> 

        #         @writeHead = (statusCode) ->
        #             statusCode.should.equal 405
        #             done()

        #         @mockRequest.url = '/v1/hubs/1/middlewares/title/replace'
        #         @mockRequest.method = 'GET'
        #         _manager().requestHandler @mockRequest, @mockResponse


        #     it 'responds 415 to if not text/javascript or text/coffeescript', (done) ->

        #         @writeHead = (statusCode) ->
        #             statusCode.should.equal 415
        #             done()

        #         @mockRequest.url = '/v1/hubs/1/middlewares/title/replace'
        #         @mockRequest.method = 'POST'
        #         _manager().requestHandler @mockRequest, @mockResponse

        #     xit 'accepts text/javascript', (done) -> 

        #         @writeHead = (statusCode) ->
        #             statusCode.should.equal 200
        #             done()

        #         @mockRequest.url = '/v1/hubs/1/middlewares/title/replace'
        #         @mockRequest.method = 'POST'
        #         @mockRequest.headers['content-type'] = 'text/javascript'
        #         @mockRequest.body = ''
        #         _manager().requestHandler @mockRequest, @mockResponse


        #     xit 'accepts text/coffee-script', (done) ->

        #         @writeHead = (statusCode) ->
        #             statusCode.should.equal 200
        #             done()

        #         @mockRequest.url = '/v1/hubs/1/middlewares/title/replace'
        #         @mockRequest.method = 'POST'
        #         @mockRequest.headers['content-type'] = 'text/coffeescript'
        #         @mockRequest.body = ''
        #         _manager().requestHandler @mockRequest, @mockResponse


        #     it 'responds 400 on eval failed', (done) -> 

        #         STATUS = undefined
        #         @writeHead = (statusCode) -> STATUS = statusCode
                    
        #         @write = (body) -> 
        #             STATUS.should.equal 400
        #             JSON.parse( body ).should.eql 
        #                 error: 'SyntaxError: Unexpected token )'
        #             done()


        #         Notifier = notifier()
        #         instance = Notifier.create 'hub name', 1
        #         instance.use 
        #             title: 'title'
        #             (next) -> next()

        #         @serializeHub1 = -> instance.serialize(2)
        #         @got        = instance.got
        #         @force      = instance.force

        #         @mockRequest.url = '/v1/hubs/1/middlewares/title/replace'
        #         @mockRequest.method = 'POST'
        #         @mockRequest.headers['content-type'] = 'text/javascript'
        #         @mockRequest.body = """

        #         fn = function )(

        #         """
        #         _manager().requestHandler @mockRequest, @mockResponse

        #     it 'responds 400 on not a function', (done) -> 

        #         STATUS = undefined
        #         @writeHead = (statusCode) -> STATUS = statusCode
                    
        #         @write = (body) -> 
        #             STATUS.should.equal 400
        #             JSON.parse( body ).should.eql 
        #                 error: 'Error: Requires middleware function'
        #             done()


        #         Notifier = notifier()
        #         instance = Notifier.create 'hub name', 1
        #         instance.use 
        #             title: 'title'
        #             (next) -> next()

        #         @serializeHub1 = -> instance.serialize(2)
        #         @got        = instance.got
        #         @force      = instance.force

        #         @mockRequest.url = '/v1/hubs/1/middlewares/title/replace'
        #         @mockRequest.method = 'POST'
        #         @mockRequest.headers['content-type'] = 'text/javascript'
        #         @mockRequest.body = """

        #         fn = 1

        #         """
        #         _manager().requestHandler @mockRequest, @mockResponse


        #     it 'replaces the middleware', (done) -> 

        #         Notifier = notifier()
        #         instance = Notifier.create 'hub name', 1
        #         instance.use 
        #             title: 'title'
        #             (next) -> next()

        #         @serializeHub1 = -> instance.serialize(2)
        #         @got        = instance.got
        #         @force      = instance.force

        #         @mockRequest.url = '/v1/hubs/1/middlewares/title/replace'
        #         @mockRequest.method = 'POST'
        #         @mockRequest.headers['content-type'] = 'text/javascript'
        #         @mockRequest.body = """
        #         fn = function() {  throw 'okgood'; }
        #         """
        #         _manager().requestHandler @mockRequest, @mockResponse

        #         instance.event (err, capsule) -> 

        #             err.should.equal 'okgood'
        #             done()

        #     it 'compiles as coffeescript according to content-type', (testDone) -> 

        #         Notifier = notifier()
        #         instance = Notifier.create 'hub name', 1
        #         instance.cache = TESTDONE: testDone
        #         instance.use 
        #             title: 'title'
        #             (next) -> next()

        #         @serializeHub1 = -> instance.serialize(2)
        #         @got        = instance.got
        #         @force      = instance.force

        #         @mockRequest.url = '/v1/hubs/1/middlewares/title/replace'
        #         @mockRequest.method = 'POST'
        #         @mockRequest.headers['content-type'] = 'text/coffeescript'
        #         @mockRequest.body = """

        #         fn = (next, capsule, {cache}) -> 
                    
        #             capsule.$$set

        #                 Done: false
        #                 watched: (change) -> cache.TESTDONE() if change.to 

        #             next()
        #         """
        #         _manager().requestHandler @mockRequest, @mockResponse

        #         instance.event (err, capsule) -> 

        #             #console.log err
        #             capsule.Done = true
                    



        #     # as text/javascript or text/coffee-script 
        # context 'DELETE /v1/hubs/:uuid:/middlewares/:title:', ->


        # context 'POST /vi/hubs/:uuid:/configure', -> 

        #     it 'modifies introspection level'
        #     it 'and possibly other things'

        # context 'GET /v1/hubs/:uuid:/reset', -> 

        #     it 'zeroes all metric counters'




