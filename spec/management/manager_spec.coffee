http       = require 'http'
https      = require 'https'
should     = require 'should'
request    = require 'request'
{parallel} = require 'also'
# {_notifier,notifier} = require '../../lib/notice/notifier'
{hub,_hub}         = require '../../lib/notice/hub/hub'
{manager,_manager} = require '../../lib/management/manager'
{NoticeableClass}  = require '../../lib/tools'



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
                
                -> Hub.create 
                        title: 'Hub One'
                        uuid: 1
                        tools: 
                            toolName: new NoticeableClass

                            

                -> Hub.create title: 'Hub Two', uuid: 2

            ]).then(
                (hubs) -> 
                    hub1 = hubs[0]
                    hub2 = hubs[1]

                    client = 
                        get: ({path}, callback) -> 
                            request.get 'http://localhost:40404' + path,
                                auth:
                                    user: 'user'
                                    pass: 'pass'
                                    immediately: true
                                (err, {statusCode}, body) -> 
                                    
                                    callback err, 
                                        statusCode: statusCode
                                        body: try JSON.parse body

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
                (err, {statusCode}) -> 

                    statusCode.should.equal 404
                    done()


        it 'responds to /about', (done) -> 

            client.get 
                path: '/about'
                (err, {statusCode, body}) -> 

                    statusCode.should.equal 200
                    body.should.eql 

                        module: 'notice'
                        version: '0.0.12'
                        doc: 'https://github.com/nomilous/notice/tree/master/spec/management'
                        endpoints: 

                            "/about":
                                description: "show this"
                                methods: [ "GET" ]

                            "/v1/hubs":
                                description: "list present hubs"
                                methods: [ "GET" ]
                            
                            "/v1/hubs/:uuid:":
                                description: "get a hub"
                                methods: [ "GET" ]
                            
                            "/v1/hubs/:uuid:/stats":
                                description: "get only the hub stats"
                                methods: [ "GET" ]
                            
                            "/v1/hubs/:uuid:/errors": 
                                description: "get only the recent errors"
                                methods: [ "GET" ]
                            
                            "/v1/hubs/:uuid:/cache":
                                description: "get output from a serailization of the traversal cache"
                                methods: [ "GET" ]
                            
                            "/v1/hubs/:uuid:/cache/**/*":
                                description: "get nested subkey from the cache tree"
                                methods: [ "GET" ]

                            "/v1/hubs/:uuid:/tools":
                                description: "get output from a serailization of the tools tree"
                                methods: [ "GET" ]

                            "/v1/hubs/:uuid:/tools/**/*":
                                description: "get nested subkey from the tools key"
                                methods: [ "GET" ]

                            "/v1/hubs/:uuid:/clients":
                                description: "pending"
                                methods: [ "GET" ]

                            "/v1/hubs/:uuid:/middlewares":
                                description: "get only the middlewares"
                                methods: [ "GET" ]
                            
                            "/v1/hubs/:uuid:/middlewares/:title:":
                                description: "get or update or delete a middleware"
                                methods: [ "GET" ]

                            "/v1/hubs/:uuid:/middlewares/:title:/disable":
                                description: "disable a middleware"
                                methods: [ "GET" ]

                            "/v1/hubs/:uuid:/middlewares/:title:/enable":
                                description: "enable a middleware"
                                methods: [ "GET" ]

                            "/v1/hubs/:uuid:/middlewares/:title:/replace":
                                description: "replace a middleware"
                                methods: [ "POST" ]
                                accepts: [ "text/javascript", "text/coffeescript" ]

                    done()  
                


        it 'responds to GET /v1/hubs with a list of records for each hub', (done) -> 

            client.get 
                path: '/v1/hubs' 
                (err, {statusCode, body}) -> 

                    statusCode.should.equal 200
                    body.should.eql 

                        '1': 
                            title: 'Hub One'
                            uuid: 1
                            stats: 
                                pipeline:
                                    input: 
                                        count: 0
                                    processing:
                                        count: 0
                                    output:
                                        count: 0
                                    error: 
                                        usr: 0
                                        sys: 0
                                    cancel:
                                        usr: 0
                                        sys: 0

                        '2':
                            title: 'Hub Two'
                            uuid: 2
                            stats: 
                                pipeline:
                                    input: 
                                        count: 0
                                    processing:
                                        count: 0
                                    output:
                                        count: 0
                                    error: 
                                        usr: 0
                                        sys: 0
                                    cancel:
                                        usr: 0
                                        sys: 0

                    done()


        context '/v1/hubs/:uuid:/', -> 

            it 'respods 404 to no such', (done) -> 

                client.get 
                    path: '/v1/hubs/9'
                    (err, {statusCode}) ->

                        statusCode.should.equal 404
                        done() 


            it 'responds with specific hub record', (done) -> 

                client.get 
                    path: '/v1/hubs/1'
                    (err, {statusCode, body}) ->

                        body.cache.should.eql {}
                        should.exist body.tools.toolName
                        body.errors.should.eql recent: []
                        body.middlewares.should.eql {}
                        done()

            it 'lists middlewares', (done) -> 

                hub1.use 
                    title: 'Middleware Title'
                    (next) -> next()

                client.get 
                    path: '/v1/hubs/1'
                    (err, {statusCode, body}) ->

                        should.exist body.middlewares[1]
                        done()


            it './stats', (done) -> 

                client.get 
                    path: '/v1/hubs/1/stats'
                    (err, {statusCode, body}) ->

                        should.exist body.pipeline
                        done()


            it './errors', (done) -> 

                client.get 
                    path: '/v1/hubs/1/errors'
                    (err, {statusCode, body}) ->

                        should.exist body.recent
                        done()



            it './cache', (done) -> 

                hub1.use 
                    slot: 1
                    title: 'add to cache'
                    (next, capsule, {cache}) -> 

                        cache.key = 'VALUE'
                        next()


                hub1.event().then -> 

                    client.get
                        path: '/v1/hubs/1'
                        (err, {statusCode, body}) ->

                    client.get 
                        path: '/v1/hubs/1/cache'
                        (err, {statusCode, body}) ->

                            body.key.should.equal 'VALUE'
                            delete hub1.cache.key
                            done()   


            it './cache/**/*', (done) -> 

                hub1.use 
                    slot: 1
                    title: 'add hash to cache for drilling'
                    (next, capsule, {cache}) -> 

                        cache.key2 = nest: some: stuff: here: 'VALUE'
                        next()


                hub1.event().then -> 
                    client.get 
                        path: '/v1/hubs/1/cache/key2/nest/some/stuff'
                        (err, {statusCode, body}) ->

                            body.here.should.equal 'VALUE'
                            done()


            xit 'responds to POST /v1/hubs/:uuid:/cache/**/* by replacing the specified key in the hash', (done) -> 




            it './tools', (done) ->

                client.get 
                    path: '/v1/hubs/1/tools'
                    (err, {statusCode, body}) ->

                        should.exist body.toolName
                        done()


            context './tools/**/*', ->

                it 'responds with the tool searialization', (done) ->

                    client.get 
                        path: '/v1/hubs/1/tools/toolName'
                        (err, {statusCode, body}) ->

                            body.should.eql 

                                apiProperty: 
                                    deeper: 'value'
                                apiFunction: {}
                                array: 
                                    '0': 'this'
                                    '1': 'is'
                                    '2': 'listified'

                            done()


                it 'walks into the tool/apiFunction async result', (done) -> 

                    client.get 
                        path: '/v1/hubs/1/tools/toolName/apiFunction/async/'
                        (err, {statusCode, body}) ->

                            body.should.eql jump: in: 'path'
                            done()



                it './clients', (done) -> 

                    client.get 
                        path: '/v1/hubs/1/clients'
                        (err, {statusCode, body}) ->

                            body.should.equal 'PENDING'
                            done()


                it './middlewares', (done) -> 

                    hub2.use

                        title: 'Middleware Title'
                        description: 'It helps'
                        (next) -> next()

                    hub2.use
                    
                        title: 'Another'
                        (next) -> next()


                    client.get 
                        path: '/v1/hubs/2/middlewares'
                        (err, {statusCode, body}) ->

                            body[1].slot.should.equal 1
                            body[1].title.should.equal 'Middleware Title'
                            body[1].type.should.equal 'usr'
                            body[1].enabled.should.equal true

                            should.exist body[2]
                            done()



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




