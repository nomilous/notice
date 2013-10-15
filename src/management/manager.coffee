{authenticator} = require './authenticator'
{missingConfig} = require '../notice/errors'
{start}         = require '../notice/hub/listener'
{readFileSync}  = require 'fs'
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
                        # TODO_LINK
                        doc: 'https://github.com/nomilous/notice/tree/develop/spec/management'
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
                    local.respond 
                        records: [notifier.serialize(2).metrics]
                        statusCode
                        response

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

                    local.respond 
                        records: [notifier.serialize(2).errors]
                        statusCode
                        response

            '/v1/hubs/:uuid:/middlewares': 

                description: 'get only the middlewares'
                methods: ['GET']
                handler: ([uuid], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.uuids[uuid]
                    notifier = local.hubContext.uuids[uuid]
                    local.respond 
                        records: notifier.serialize(2).middlewares
                        statusCode
                        response

            '/v1/hubs/:uuid:/middlewares/:title:':

                description: 'get or update or delete a middleware'
                methods: ['GET', 'DELETE']
                handler: ([uuid,title], request, response, statusCode = 200) -> 

                    title = decodeURIComponent title
                    notifier = local.hubContext.uuids[uuid]
                    middlewares = notifier.serialize(2).middlewares
                    for middleware in middlewares
                        if middleware.title == title
                            return local.respond middleware, statusCode, response

                    objectNotFound response





    port         = listen.port
    address      = if listen.hostname? then listen.hostname else '127.0.0.1'
    opts         = {}
    opts.key     = listen.key
    opts.cert    = listen.cert

    {server, transport} = start opts, local.requestHandler = authenticated (request, response) ->

        path = request.url
        if path[-1..] == '/' then path = path[0..-2]

        try 
            [match, uuid] = matched = path.match /v1\/hubs\/(.*)/
            unless uuid.match /\//
                return local.routes['/v1/hubs/:uuid:'].handler [uuid], request, response

            if [match, uuid, nested] = uuid.match /(.*?)\/(.*)/
                unless nested.match /\//
                    return local.routes["/v1/hubs/:uuid:/#{nested}"].handler [uuid], request, response
                
                if [match, nested, title] = nested.match /(.*?)\/(.*)/
                    return local.routes["/v1/hubs/:uuid:/#{nested}/:title:"].handler [uuid, title], request, response

        catch error


        unless local.routes[path]? 

            # #
            # # request for undefined route, respond 404 (but with help)
            # #
            # return local.routes['/about'].handler null, request, response, 404 

            response.writeHead 404
            return response.end()

        
        local.routes[path].handler null, request, response
            


    server.listen port, address, -> 
        {address, port} = server.address()
        console.log 'API @ %s://%s:%s', 
            transport, address, port


    return api = 
        register: local.register

