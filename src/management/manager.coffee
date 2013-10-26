{authenticator} = require './authenticator'
{missingConfig} = require '../notice/errors'
{start}         = require '../notice/hub/listener'
{recursor}      = require './recursor'
{readFileSync}  = require 'fs'
coffee          = require 'coffee-script'
Version         = JSON.parse( readFileSync __dirname + '/../../package.json', 'utf8' ).version

testable               = undefined
module.exports._manager = -> testable
module.exports.manager  = (config = {}) ->

    try listen    = config.manager.listen
    authenticated = authenticator config

    unless listen?
        throw missingConfig 'config.manager.listen', 'manager' 

    unless typeof listen.port is 'number'
        throw missingConfig 'config.manager.listen.port', 'manager'

    testable = local = 

        hubContext: undefined
        register: (hubContext) -> local.hubContext = hubContext

        methodNotAllowed: (response) -> 

            response.writeHead 405
            response.end()

        objectNotFound: (response) -> 

            response.writeHead 404
            response.end()

        unsupportedMedia: (response) -> 

            response.writeHead 415
            response.end()


        respond: (data, statusCode, response) -> 

            body = JSON.stringify data, null, 2
            response.writeHead statusCode,
                'Content-Type': 'application/json'
                'Content-Length': body.length

            response.write body
            response.end()


        middleware: (action, hub, slot, body, response, statusCode) ->

            local[ action + 'Middleware'] hub, slot, {}


            # curl -XPUT -u user: :20002/v1/hubs/1/middlewares/10 -d '...'

            console.log
                SLOT: slot
                BODY: body



            # local.respond {}, 200, response



        insertMiddleware: (hub, slot, middleware) -> 

            # 
            # POST /v1/hubs/:uuid:/middlewares
            # --------------------------------
            # 
            # * inserts a new midleware at the back of the bus
            # * slot argument in body is illegal
            # * PUT is illegal
            # 

            


        upsertMiddleware: (hub, slot, middleware) -> 

            #
            # POST or PUT /v1/hubs/:uuid:/middlewares/:slot:
            # ----------------------------------------------
            # 
            # * create or update middleware at particular slot
            # * slot agrument in body is illegal
            # * respond 200 on updated
            # * respond 201 on created
            # 




    local.routes =

            '/about': 

                description: 'show this'
                methods: ['GET']
                handler: (matched, request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    local.respond
                        module:  'notice'
                        version: Version
                        doc: 'https://github.com/nomilous/notice/tree/master/spec/management'
                        endpoints: local.routes

                        statusCode
                        response



            '/v1/hubs': 

                description: 'list present hubs'
                methods: ['GET']
                handler: (matched, request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    
                    result = {}
                    hubs   = local.hubContext.hubs
                    result[uuid] = hubs[uuid].serialize(1) for uuid of hubs
                    # result[uuid] = hubs[uuid] for uuid of hubs
                    # 
                    # nice!
                    #
                    
                    local.respond result,
                        statusCode
                        response

            '/v1/hubs/:uuid:': 

                description: 'get a hub'
                methods: ['GET']
                handler: ([uuid], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.hubs[uuid]

                    notifier = local.hubContext.hubs[uuid]
                    local.respond notifier.serialize(2), statusCode, response

            '/v1/hubs/:uuid:/stats': 

                description: 'get only the hub stats'
                methods: ['GET']
                handler: ([uuid], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.hubs[uuid]

                    notifier = local.hubContext.hubs[uuid]
                    local.respond(
                        notifier.serialize(2).stats
                        statusCode
                        response
                    )

            '/v1/hubs/:uuid:/errors': 

                description: 'get only the recent errors'
                methods: ['GET']
                handler: ([uuid], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.hubs[uuid]
                    
                    notifier = local.hubContext.hubs[uuid]
                    
                    #
                    # * responds with the recent array inside the records array which is a bit messy
                    #   but it's likely that more items will be added to the errors branch
                    #

                    local.respond(
                        notifier.serialize(2).errors
                        statusCode
                        response
                    )

            '/v1/hubs/:uuid:/cache': 

                description: 'get output from a serailization of the traversal cache'
                methods: ['GET']
                handler: ([uuid], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.hubs[uuid]
                    notifier = local.hubContext.hubs[uuid]
                    local.respond( 
                        notifier.serialize(2).cache
                        statusCode
                        response
                    )

            '/v1/hubs/:uuid:/cache/**/*': 

                description: 'get nested subkey from the cache tree'
                methods: ['GET'] #, 'POST'] #, 'DELETE']
                handler: ([uuid, deeper], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.hubs[uuid]
                    notifier = local.hubContext.hubs[uuid]
                    cache = notifier.serialize(2).cache

                    deeper.split('/').map (key) -> 
                        key = decodeURIComponent key
                        cache = cache[key]

                    local.respond( 
                        cache
                        statusCode
                        response
                    )


            '/v1/hubs/:uuid:/tools': 

                description: 'get output from a serailization of the tools tree'
                methods: ['GET']
                handler: recursor local, 'tools'

            '/v1/hubs/:uuid:/tools/**/*': 

                description: 'get nested subkey from the tools key'
                methods: ['GET'] 
                handler: recursor local, 'tools' 


            '/v1/hubs/:uuid:/clients': 

                description: 'pending'
                methods: ['GET']
                handler: ([uuid], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.hubs[uuid]
                    notifier = local.hubContext.hubs[uuid]
                    local.respond( 
                        'PENDING'
                        statusCode
                        response
                    )


            '/v1/hubs/:uuid:/middlewares': 

                description: 'get only the middlewares'
                methods: ['GET', 'POST']
                handler: ([hubuuid,nothing,authenticEntity], {method, body}, response, statusCode = 200) -> 

                    console.log moo: 1

                    if method == 'POST'
                        return local.objectNotFound response unless local.hubContext.hubs[hubuuid]
                        notifier = local.hubContext.hubs[hubuuid]
                        return local.middleware 'insert', notifier, null, body, response, statusCode

                    return local.methodNotAllowed response unless method == 'GET'
                    return local.objectNotFound response unless local.hubContext.hubs[hubuuid]
                    notifier = local.hubContext.hubs[hubuuid]
                    local.respond(
                        notifier.serialize(2).middlewares
                        statusCode
                        response
                    )


            '/v1/hubs/:uuid:/middlewares/:slot:':

                description: 'get or update or delete a middleware'
                methods: ['GET', 'PUT', 'POST'] # , 'DELETE']
                handler: ([hubuuid,slot,authenticEntity], {method, body}, response, statusCode = 200) -> 

                    if method == 'POST' or method == 'PUT'
                        return local.objectNotFound response unless local.hubContext.hubs[hubuuid]
                        notifier = local.hubContext.hubs[hubuuid]
                        return local.middleware 'upsert', notifier, slot, body, response, statusCode

                    return local.methodNotAllowed response unless method == 'GET'
                    return local.objectNotFound response unless local.hubContext.hubs[hubuuid]

                    notifier = local.hubContext.hubs[hubuuid]
                    middlewares = notifier.serialize(2).middlewares
                    try return local.respond middlewares[slot], statusCode, response
                    objectNotFound response


            '/v1/hubs/:uuid:/middlewares/:slot:/disable':
                description: 'disable a middleware'
                methods: ['GET']
                handler: ([uuid,slot,authenticEntity], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.hubs[uuid]

                    notifier = local.hubContext.hubs[uuid]
                    notifier.use slot: slot, enabled: false, update: true
                    middlewares = notifier.serialize(2).middlewares
                    return local.respond  middlewares[slot], statusCode, response
                    objectNotFound response


            '/v1/hubs/:uuid:/middlewares/:slot:/enable':
                description: 'enable a middleware'
                methods: ['GET']
                handler: ([uuid,slot,authenticEntity], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.hubs[uuid]

                    notifier = local.hubContext.hubs[uuid]
                    notifier.use slot: slot, enabled: true, update: true
                    middlewares = notifier.serialize(2).middlewares
                    return local.respond  middlewares[slot], statusCode, response
                    objectNotFound response


            # '/v1/hubs/:uuid:/middlewares/:title:/replace':
            #     description: 'replace a middleware'
            #     methods: ['POST']
            #     accepts: ['text/javascript', 'text/coffeescript']
            #     handler: ([uuid,title], request, response, statusCode = 200) -> 

            #         return local.methodNotAllowed response unless request.method == 'POST'
            #         return local.unsupportedMedia response unless (
            #             request.headers['content-type'] == 'text/javascript' or
            #             request.headers['content-type'] == 'text/coffeescript'
            #         )

            #         title = decodeURIComponent title
            #         notifier = local.hubContext.uuids[uuid]
            #         return local.objectNotFound response unless notifier.got title

            #         apply = (fn) -> 
            #             unless typeof fn is 'function'
            #                 return local.respond
            #                     error: ( new Error 'Requires middleware function' ).toString()
            #                     400
            #                     response

            #             notifier.force title: title, fn
            #             response.writeHead 200
            #             return response.end()


            #         body = ''
            #         request.on 'data', (buf) -> body += buf.toString()
            #         request.on 'end', -> 

            #             if request.headers['content-type'] == 'text/coffeescript'
            #                 try body = coffee.compile body, bare: true
            #                 catch error
            #                     return local.respond
            #                         error: error.toString()
            #                         400
            #                         response

            #             try fn = eval body
            #             catch error
            #                 return local.respond
            #                     error: error.toString()
            #                     400
            #                     response

            #             return apply fn




    port         = listen.port
    address      = if listen.hostname? then listen.hostname else '127.0.0.1'
    opts         = {}
    opts.key     = listen.key
    opts.cert    = listen.cert

    {server, transport} = start opts, local.requestHandler = authenticated (authenticEntity, request, response) ->

        #
        # ##undecided1
        # 
        ##
        ## * keep in mind (for later) the posibility of an inbound request body containing a stream 
        ##   of notable size, and the posibility that a $$notice api plugin might ALSO prefer:
        ##      * to receive it in chunks
        ##      * that this decoder did not also decode it
        ## 
        ## * for now, this decodes the entire inbound stream into memory, with an assumption 
        ##   that it is a small piece of text content (in a utf8 buffer).
        ##
        ######
            ##

        body  = ''
        error = false
        request.on 'error', -> 
            
            error = true


        #
        # TODO: What does node http server do when an inbound stream stops midway
        #       without 'error' or 'end'. Or 'is that possible'. These running 
        #       handlers will accumulate in those cases.
        #

        request.on 'data', (data) -> body += data.toString()
        request.on 'end', -> 

            return if error
            ##
            ##
            # * nice thing aboud pub sub is more than one pub can be subbing
            # * $$notice api function could be provided with the request's EventEmitter
            #       * complexity arises on the question around who makes the response
            #       * which is what makes the connect stack such a masterstroke, 
            #       * makes that a question of sequence, 
            #       * early bird gets the wormhole,
            #       * and closes it.
            # * ?ways? for a $$notice apiFunction to inform this decoder not to load
            #          an inbound stream into memory
            #
            # * and the path
            # * and the headers
            #  

            request.body = body
            path = request.url

            if path == '/about' or path == '/'
                return local.routes["/about"].handler [], request, response
                
            if path[-1..] == '/' then path = path[0..-2]

            try      
                [match, version, base, uuid, nested, slot, action] = path.match /(.*)\/(.*)\/(.*)\/(.*)\/(.*)\/(.*)/
                return local.routes["#{version}/#{base}/:uuid:/#{nested}/:slot:/#{action}"].handler [uuid, slot, authenticEntity], request, response
            try
                [match, version, base, uuid, nested, slot] = path.match /(.*)\/(.*)\/(.*)\/(.*)\/(.*)/
                return local.routes["#{version}/#{base}/:uuid:/#{nested}/:slot:"].handler [uuid, slot, authenticEntity], request, response
            try
                [match, version, base, uuid, nested] = path.match /(.*)\/(.*)\/(.*)\/(.*)/
                
                try if [match, uuid, deeper] = path.match /v1\/hubs\/(.*)\/cache\/(.*)/
                    return local.routes["/v1/hubs/:uuid:/cache/**/*"].handler [uuid, deeper], request, response
                
                try if [match, uuid, deeper] = path.match /v1\/hubs\/(.*)\/tools\/(.*)/
                    return local.routes["/v1/hubs/:uuid:/tools/**/*"].handler [uuid, deeper, authenticEntity], request, response

                return local.routes["#{version}/#{base}/:uuid:/#{nested}"].handler [uuid], request, response
            try
                [match, version, base, uuid] = path.match /(.*)\/(.*)\/(.*)/
                return local.routes["#{version}/#{base}/:uuid:"].handler [uuid], request, response
            try
                [match, version, base] = path.match /(.*)\/(.*)/
                return local.routes["#{version}/#{base}"].handler [], request, response

            return local.objectNotFound response

    server.listen port, address, -> 
        {address, port} = server.address()
        console.log 'API @ %s://%s:%s', 
            transport, address, port


    return api = 
        register: local.register

