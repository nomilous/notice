{authenticator} = require './authenticator'
{missingConfig} = require '../notice/errors'
{start}         = require '../notice/hub/listener'
{readFileSync}  = require 'fs'
coffee          = require 'coffee-script'
version         = JSON.parse( readFileSync __dirname + '/../../package.json', 'utf8' ).version

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


        routes: 

            '/about': 

                description: 'show this'
                methods: ['GET']
                handler: (matched, request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    local.respond
                        module:  'notice'
                        version: version
                        doc: 'https://github.com/nomilous/notice/tree/master/spec/management'
                        endpoints: local.routes

                        statusCode
                        response



            '/v1/hubs': 

                description: 'list present hubs'
                methods: ['GET']
                handler: (matched, request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    data = records: []
                    for hubname of local.hubContext.hubs
                        uuid = local.hubContext.hubs[hubname].uuid
                        notifier  = local.hubContext.uuids[uuid]
                        data.records.push notifier.serialize(1)

                    local.respond data,
                        statusCode
                        response

            '/v1/hubs/:uuid:': 

                description: 'get a hub'
                methods: ['GET']
                handler: ([uuid], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.uuids[uuid]

                    notifier = local.hubContext.uuids[uuid]
                    local.respond notifier.serialize(2), statusCode, response

            '/v1/hubs/:uuid:/metrics': 

                description: 'get only the metrics'
                methods: ['GET']
                handler: ([uuid], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.uuids[uuid]

                    notifier = local.hubContext.uuids[uuid]
                    local.respond(
                        notifier.serialize(2).metrics
                        statusCode
                        response
                    )

            '/v1/hubs/:uuid:/errors': 

                description: 'get only the recent errors'
                methods: ['GET']
                handler: ([uuid], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.uuids[uuid]
                    
                    notifier = local.hubContext.uuids[uuid]
                    
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

                description: 'get the accumulated content from the traversal cache'
                methods: ['GET']
                handler: ([uuid], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.uuids[uuid]
                    notifier = local.hubContext.uuids[uuid]
                    local.respond( 
                        notifier.serialize(2).cache
                        statusCode
                        response
                    )

            '/v1/hubs/:uuid:/cache/**/*': 

                description: 'get nested subkey from the traversal cache'
                methods: ['GET'] #, 'POST'] #, 'DELETE']
                handler: ([uuid, deeper], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.uuids[uuid]
                    notifier = local.hubContext.uuids[uuid]
                    cache = notifier.serialize(2).cache

                    deeper.split('/').map (key) -> 
                        key = decodeURIComponent key
                        cache = cache[key]

                    local.respond( 
                        cache
                        statusCode
                        response
                    )

            '/v1/hubs/:uuid:/clients': 

                description: 'pending'
                methods: ['GET']
                handler: ([uuid], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.uuids[uuid]
                    notifier = local.hubContext.uuids[uuid]
                    local.respond( 
                        notifier.serialize(2).clients
                        statusCode
                        response
                    )

            # 
            # 
            # '/v1/hubs/:uuid:/cache/:key:': 
            # 
            #     description: 'create or update or delete objects on the traversal cache'
            #     methods: ['GET', POST','DELETE']
            #     accepts: ['application/json']
            #     handler: ([uuid], request, response, statusCode = 200) -> 
            #
            # 

            '/v1/hubs/:uuid:/middlewares': 

                description: 'get only the middlewares'
                methods: ['GET']
                handler: ([uuid], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.uuids[uuid]
                    notifier = local.hubContext.uuids[uuid]
                    local.respond(
                        notifier.serialize(2).middlewares
                        statusCode
                        response
                    )


            '/v1/hubs/:uuid:/middlewares/:title:':

                description: 'get or update or delete a middleware'
                methods: ['GET'] #['GET', 'DELETE']
                handler: ([uuid,title], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.uuids[uuid]

                    title = decodeURIComponent title
                    notifier = local.hubContext.uuids[uuid]
                    middlewares = notifier.serialize(2).middlewares
                    try return local.respond middlewares[title], statusCode, response
                    objectNotFound response


            '/v1/hubs/:uuid:/middlewares/:title:/disable':
                description: 'disable a middleware'
                methods: ['GET']
                handler: ([uuid,title], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.uuids[uuid]

                    title = decodeURIComponent title
                    notifier = local.hubContext.uuids[uuid]
                    return objectNotFound response unless notifier.got title
                    notifier.force title: title, enabled: false
                    middlewares = notifier.serialize(2).middlewares
                    return local.respond  middlewares[title], statusCode, response
                    objectNotFound response


            '/v1/hubs/:uuid:/middlewares/:title:/enable':
                description: 'enable a middleware'
                methods: ['GET']
                handler: ([uuid,title], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.uuids[uuid]

                    title = decodeURIComponent title
                    notifier = local.hubContext.uuids[uuid]
                    return objectNotFound response unless notifier.got title
                    notifier.force title: title, enabled: true
                    middlewares = notifier.serialize(2).middlewares
                    return local.respond  middlewares[title], statusCode, response
                    objectNotFound response


            '/v1/hubs/:uuid:/middlewares/:title:/replace':
                description: 'replace a middleware'
                methods: ['POST']
                accepts: ['text/javascript', 'text/coffee-script']
                handler: ([uuid,title], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'POST'
                    return local.unsupportedMedia response unless (
                        request.headers['content-type'] == 'text/javascript' or
                        request.headers['content-type'] == 'text/coffee-script'
                    )

                    title = decodeURIComponent title
                    notifier = local.hubContext.uuids[uuid]
                    return local.objectNotFound response unless notifier.got title

                    apply = (fn) -> 
                        unless typeof fn is 'function'
                            return local.respond
                                error: ( new Error 'Requires middleware function' ).toString()
                                400
                                response

                        notifier.force title: title, fn
                        response.writeHead 200
                        return response.end()


                    body = ''
                    request.on 'data', (buf) -> body += buf.toString()
                    request.on 'end', -> 

                        if request.headers['content-type'] == 'text/coffee-script'
                            try body = coffee.compile body, bare: true
                            catch error
                                return local.respond
                                    error: error.toString()
                                    400
                                    response

                        try fn = eval body
                        catch error
                            return local.respond
                                error: error.toString()
                                400
                                response

                        return apply fn




    port         = listen.port
    address      = if listen.hostname? then listen.hostname else '127.0.0.1'
    opts         = {}
    opts.key     = listen.key
    opts.cert    = listen.cert

    {server, transport} = start opts, local.requestHandler = authenticated (request, response) ->

        path = request.url

        if path == '/about' or path == '/'
            return local.routes["/about"].handler [], request, response
            
        if path[-1..] == '/' then path = path[0..-2]

        try      
            [match, version, base, uuid, nested, title, action] = path.match /(.*)\/(.*)\/(.*)\/(.*)\/(.*)\/(.*)/
            return local.routes["#{version}/#{base}/:uuid:/#{nested}/:title:/#{action}"].handler [uuid, title], request, response
        try
            [match, version, base, uuid, nested, title] = path.match /(.*)\/(.*)\/(.*)\/(.*)\/(.*)/
            return local.routes["#{version}/#{base}/:uuid:/#{nested}/:title:"].handler [uuid, title], request, response
        try
            [match, version, base, uuid, nested] = path.match /(.*)\/(.*)\/(.*)\/(.*)/
            try if [match, uuid, deeper] = path.match /v1\/hubs\/(.*)\/cache\/(.*)/
                return local.routes["/v1/hubs/:uuid:/cache/**/*"].handler [uuid, deeper], request, response

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

