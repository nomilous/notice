ipso       = require 'ipso'
{Client}   = require 'dinkum'
{parallel} = require 'also'
coffee     = require 'coffee-script'
# {_notifier,notifier} = require '../../lib/notice/notifier'
{hub,_hub}         = require '../../lib/notice/hub/hub'
{manager,_manager} = require '../../lib/management/manager'
{NoticeableClass}  = require '../../lib/tools'


describe 'manage', ipso (should, http, https) ->

    beforeEach -> 
        @createHttp = http.createServer
        @createHttps = https.createServer
        @compile = coffee.compile

    afterEach -> 
        http.createServer = @createHttp
        https.createServer = @createHttps
        coffee.compile = @compile


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

    
    context 'middleware', -> 

        beforeEach (done) -> 

            @hub = {}

            http.createServer = -> listen: -> done()
            Manager = manager
                manager:
                    authenticate: {}
                    listen: 
                        port: 9999

            Manager.register 

                hubs: UUID: @hub



        it 'compiles text/coffee-script without enclosing', (done) -> 

            #
            # TODO: litcoffee too, ...a whole nother kettle of beans (to blend in interesting ways)
            #

            coffee.compile = (body, opts) -> 

                body.should.equal 'BODY'
                opts.bare.should.equal true
                done()
                throw 'go no further'

            try _manager().middleware 'insert', @hub, null, 'text/coffeescript', 'BODY', 
                writeHead: ->
                write: ->
                end: ->



        it 'inserts middleware', (done) -> 

            _manager().insertMiddleware = -> done()
            _manager().middleware 'insert', @hub, null, 'text/javascript', 'body', 
                writeHead: ->
                write: ->
                end: ->


        it 'upserts middleware', (done) -> 

            _manager().upsertMiddleware = -> done()
            _manager().middleware 'upsert', @hub, null, 'text/coffeescript', 'body', 
                writeHead: ->
                write: ->
                end: ->


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

                    client = Client.create

                        content: 

                            #
                            # TODO: move this to dinkum as one of the bundled 
                            #       content-type serailizers
                            #

                            'text/coffeescript':
                                encode: (opts) -> 
                                    opts.body = opts['text/coffeescript']
                                    opts.headers ||= {}
                                    opts.headers['content-type'] = 'text/coffeescript'


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


        it 'responds with 404 incase of no route',ipso (done) -> 

            client.get
                path: '/no/route'
            
            .then ({statusCode}) -> 

                statusCode.should.equal 404
                done()


        it 'responds to /about', ipso (done) -> 

            client.get
                path: '/about' 

            .then ({statusCode, body}) -> 

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
                            methods: [ "GET", 'POST' ]
                            accepts: ['text/javascript', 'text/coffeescript']
                        
                        "/v1/hubs/:uuid:/middlewares/:slot:":
                            description: "get or update or delete a middleware"
                            methods: [ "GET", 'PUT', 'POST']
                            accepts: ['text/javascript', 'text/coffeescript']

                        "/v1/hubs/:uuid:/middlewares/:slot:/disable":
                            description: "disable a middleware"
                            methods: [ "GET" ]

                        "/v1/hubs/:uuid:/middlewares/:slot:/enable":
                            description: "enable a middleware"
                            methods: [ "GET" ]

                        # "/v1/hubs/:uuid:/middlewares/:title:/replace":
                        #     description: "replace a middleware"
                        #     methods: [ "POST" ]
                        #     accepts: [ "text/javascript", "text/coffeescript" ]

                done()  
            


        it 'responds to GET /v1/hubs with a list of records for each hub', ipso (done) -> 

            client.get
                path: '/v1/hubs'

            .then ({statusCode, body}) -> 

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

            it 'respods 404 to no such', ipso (done) -> 

                client.get 
                    path: '/v1/hubs/9'

                .then ({statusCode}) ->

                    statusCode.should.equal 404
                    done() 


            it 'responds with specific hub record', ipso (done) -> 

                client.get 
                    path: '/v1/hubs/1'

                .then ({statusCode, body}) ->

                    body.cache.should.eql {}
                    should.exist body.tools.toolName
                    body.errors.should.eql recent: []
                    body.middlewares.should.eql {}
                    done()

            it 'lists middlewares', ipso (done) -> 

                hub1.use 
                    title: 'Middleware Title'
                    (next) -> next()

                client.get 
                    path: '/v1/hubs/1'
                
                .then ({statusCode, body}) ->

                    should.exist body.middlewares[1]
                    done()


            it './stats', ipso (done) -> 

                client.get 
                    path: '/v1/hubs/1/stats'
                
                .then ({statusCode, body}) ->

                    should.exist body.pipeline
                    done()


            it './errors', ipso (done) -> 

                client.get 
                    path: '/v1/hubs/1/errors'
                
                .then ({statusCode, body}) ->

                        should.exist body.recent
                        done()



            it './cache', ipso (done) -> 

                hub1.use 
                    slot: 1
                    title: 'add to cache'
                    (next, capsule, {cache}) -> 

                        cache.key = 'VALUE'
                        next()


                hub1.event().then -> 

                    client.get
                        path: '/v1/hubs/1'
                    
                    .then ({statusCode, body}) ->

                        client.get 
                            path: '/v1/hubs/1/cache'
                        
                        .then ({statusCode, body}) ->

                                body.key.should.equal 'VALUE'
                                delete hub1.cache.key
                                done()   


            it './cache/**/*', ipso (done) -> 

                hub1.use 
                    slot: 1
                    title: 'add hash to cache for drilling'
                    (next, capsule, {cache}) -> 

                        cache.key2 = nest: some: stuff: here: 'VALUE'
                        next()


                hub1.event().then -> 
                    client.get 
                        path: '/v1/hubs/1/cache/key2/nest/some/stuff'
                    
                    .then ({statusCode, body}) ->

                            body.here.should.equal 'VALUE'
                            done()


            xit 'responds to POST /v1/hubs/:uuid:/cache/**/* by replacing the specified key in the hash', (done) -> 




            it './tools', ipso (done) ->

                client.get 
                    path: '/v1/hubs/1/tools'
                
                .then ({statusCode, body}) ->

                    should.exist body.toolName
                    done()


            context './tools/**/*', ->

                it 'responds with the tool searialization', ipso (done) ->

                    client.get 
                        path: '/v1/hubs/1/tools/toolName'
                    
                    .then ({statusCode, body}) ->

                            body.should.eql 

                                apiProperty: 
                                    deeper: 'value'
                                apiFunction: {}
                                array: 
                                    '0': 'this'
                                    '1': 'is'
                                    '2': 'listified'

                            done()


                it 'walks into the tool/apiFunction async result', ipso (done) -> 

                    client.get 
                        path: '/v1/hubs/1/tools/toolName/apiFunction/async/'
                    
                    .then ({statusCode, body}) ->

                        body.should.eql jump: in: 'path'
                        done()



                it './clients', ipso (done) -> 

                    client.get 
                        path: '/v1/hubs/1/clients'
                        
                    .then ({statusCode, body}) ->

                            body.should.equal 'PENDING'
                            done()


                it './middlewares', ipso (done) -> 

                    hub2.use

                        title: 'Middleware Title'
                        description: 'It helps'
                        (next) -> next()

                    hub2.use
                    
                        title: 'Another'
                        (next) -> next()


                    client.get 
                        path: '/v1/hubs/2/middlewares'
                        
                    .then ({statusCode, body}) ->

                            body[1].slot.should.equal 1
                            body[1].title.should.equal 'Middleware Title'
                            body[1].type.should.equal 'usr'
                            body[1].enabled.should.equal true

                            should.exist body[2]
                            done()


        context '/v1/hubs/:uuid:/middlewares/:slot:', ->

            it 'gets specific middleware details', ipso (done) -> 

                hub2.use

                    slot: 1
                    title: 'Middleware Title 1'
                    description: 'It helps'
                    (next) -> next()

                client.get 
                    path: '/v1/hubs/2/middlewares/1'
                    
                .then ({statusCode, body}) ->

                    body.title.should.equal 'Middleware Title 1'
                    done()


            it '404s', ipso (done) ->

                client.get 
                    path: '/v1/hubs/2/middlewares/333'
                    
                .then ({statusCode, body}) ->

                    statusCode.should.equal 404
                    done()



            it 'disables middleware with GET /v1/hubs/:uuid:/middlewares/:slot:/disable', ipso (done) -> 

                hub2.use

                    slot: 1
                    title: 'Middleware Title 1'
                    description: 'It helps'
                    (next) -> next()

                client.get 

                    path: '/v1/hubs/2/middlewares/1/disable'
                
                .then ({statusCode, body}) ->

                    body.enabled.should.equal false
                    done()

            it 'returns 404 on no such middleware', ipso (done) -> 

                client.get 

                    path: '/v1/hubs/2/middlewares/44/disable'
                
                .then  ({statusCode, body}) ->

                    statusCode.should.equal 404
                    done()


            it 'enables middleware with  GET v1/hubs/:uuid:/middlewares/:slot:/enable', ipso (done) -> 

                hub2.use

                    slot: 1
                    enabled: false
                    title: 'Middleware Title 1'
                    description: 'It helps'
                    (next) -> next()

                client.get 

                    path: '/v1/hubs/2/middlewares/1/enable'
                
                .then ({statusCode, body}) ->

                    body.enabled.should.equal true
                    done()


            context '415s on unacceptable content-type', -> 

                it 'at insert', ipso (done) -> 

                    client.post 
                        path: '/v1/hubs/2/middlewares'
                        'application/json': day: 'tah'

                    .then ({statusCode}) -> 
                        statusCode.should.equal 415
                        done()

                it 'at upsert', ipso (done) -> 

                    client.post 
                        path: '/v1/hubs/2/middlewares/21'
                        'application/json': dah: 'tah'

                    .then ({statusCode}) -> 
                        statusCode.should.equal 415
                        done()


            context '400s on compile problems', (done) -> 

                it 'at insert', ipso (done) -> 

                    client.post 

                        path: '/v1/hubs/2/middlewares/10'
                        'text/coffeescript': 'when'

                    .then ({statusCode, body}) -> 

                        statusCode.should.equal 400
                        body.should.eql 

                            error: 
                                type: 'SyntaxError'
                                message: 'unexpected WHEN'
                                location: 
                                    first_line: 0
                                    first_column: 0
                                    last_line: 0
                                    last_column: 3

                        done()


            context 'PUT', -> 

            context 'POST', ->


            #context 'DELETE'




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


        context 'POST /vi/hubs/:uuid:/configure', -> 

            it 'modifies introspection level'
            it 'and possibly other things'

        context 'GET /v1/hubs/:uuid:/reset', -> 

            it 'zeroes all metric counters'




