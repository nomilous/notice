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

    try listen    = config.api.listen
    authenticated = authenticator config

    unless listen?
        throw missingConfig 'config.api.listen', 'api' 

    unless typeof listen.port is 'number'
        throw missingConfig 'config.api.listen.port', 'api'

    testable = local = 

        hubContext: undefined
        register: (hubContext) -> local.hubContext = hubContext

        #
        # TODO: include something on the body in all nonsuccess error cases
        #

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

        badRequest: (response, data) -> 

            local.respond data, 400, response



        middleware: (action, hub, slot, contentType, body, response, statusCode) ->

            #
            # todo: (##undecided1) consider this as a $notice api fuction on the middleware collection
            #       apiFn.$notice { methods: [allowed, list] }
            #       complexity: the $notice api recursive uri walk wants to step right 
            #                   through the call and into the result tree
            #

            return local.unsupportedMedia response unless (
                contentType == 'text/javascript' or
                contentType == 'text/coffeescript'
            )


            ### 

coffeescript
============

curl -u user: -H 'Content-Type: text/coffeescript' :20002/hubs/1/middlewares -d '

title: "title"
fn: (next, capsule) -> 
    console.log capsule.$all()
    next()

'

curl -u user: -H 'Content-Type: text/coffeescript' :20002/hubs/1/middlewares -d '

title: "title"
slot:  1
fn: (next) -> next()

'

curl -u user: -H 'Content-Type: text/coffeescript' :20002/hubs/1/middlewares/10 -d '

title: "title"
fn: (next) -> next()

'

javascript
==========

curl -u user: -H 'Content-Type: text/javascript' :20002/hubs/1/middlewares/10 -d '

{ 
    title: "title",
    fn: function(next) {
        next();
    }
}

'
            
            ###

            try js = 
                if contentType == 'text/coffeescript' then coffee.compile body, bare: true
                else body

            catch error 
                errorType = try error.constructor.name
                return local.badRequest response, error: 
                    type: errorType || 'Error'
                    message: error.message
                    location: error.location

            
            try eval "var mware=#{ js }"
            catch error
                errorType = try error.constructor.name
                return local.badRequest response, error: 
                    type: errorType || 'Error'
                    message: error.message

            #
            # register the middleware onto the hub's bus
            # ------------------------------------------
            # 

            local[ action + 'Middleware'] hub, slot, mware, (error, result) ->

                # 
                # * asynchronous enables persisting middleware registrations
                # * pleasant all round if posted middleware is still present
                #   after a hub restart!
                # * BUT...
                #     * `hub.use(...)` equivalent is not able to do the same
                #     * or at least, not in the same ""direction""...
                # 
                # ALSO: ##undecided3
                # * new middle / changed middleware emits $delta capsule
                #

                if error?
                    errorType = try error.constructor.name
                    return local.badRequest response, error: 
                        type: errorType || 'Error'
                        message: error.message
                        suggestion: error.suggestion
            
                local.respond result.middleware, result.statusCode, response



        insertMiddleware: (hub, slot, middleware, callback) -> 

            # 
            # POST /hubs/:uuid:/middlewares
            # --------------------------------
            # 
            # * inserts a new midleware at the back of the bus
            # * ##undecided2 - persistance plugin(ability)
            # * slot argument in body is illegal
            # * PUT is illegal
            # 

            if middleware.slot?
                error = new Error 'notice: cannot insert middleware with already specified slot'
                error.suggestion = upsert: '[POST,PUT] /hubs/:uuid:/middlewares/:slot:'
                return callback error

            if not hub.uniqueTitle middleware.title
                error = new Error 'notice: cannot insert middleware without unique title'
                error.suggestion = upsert: '[POST,PUT] /hubs/:uuid:/middlewares/:slot:'
                return callback error

            try hub.use 
                title: middleware.title
                description: middleware.description
                enabled: middleware.enabled
                middleware.fn

            catch error

                #
                # TODO: this displays the error from hub.use (perhaps confuzing)
                #       create distinction mechanism for restAPI / libAPI
                #

                return callback error
            

            inserted = hub.serialize(2).middlewares[hub.lastSlot]

            callback null, 
                statusCode: 201
                middleware: inserted


        upsertMiddleware: (hub, slot, middleware, callback) -> 


            slot = parseInt slot


            #
            # POST or PUT /hubs/:uuid:/middlewares/:slot:
            # ----------------------------------------------
            # 
            # * create or update middleware at particular slot
            # * ##undecided2 - persistance plugin(ability)
            # * 400 if slot in body does not match :slot:
            # * respond 200 on updated
            # * respond 201 on created
            # 

            try hub.use 
                slot: slot
                title: middleware.title
                description: middleware.description
                enabled: middleware.enabled
                middleware.fn

            catch error

                return callback error

            inserted = hub.serialize(2).middlewares[slot]
            callback null, 
                statusCode: 200
                middleware: inserted


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



            '/hubs': 

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

            '/hubs/:uuid:': 

                description: 'get a hub'
                methods: ['GET']
                handler: ([query,uuid], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.hubs[uuid]

                    notifier = local.hubContext.hubs[uuid]
                    local.respond notifier.serialize(2), statusCode, response

            '/hubs/:uuid:/stats': 

                description: 'get only the hub stats'
                methods: ['GET']
                handler: ([query,uuid], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.hubs[uuid]

                    notifier = local.hubContext.hubs[uuid]
                    local.respond(
                        notifier.serialize(2).stats
                        statusCode
                        response
                    )

            '/hubs/:uuid:/errors': 

                description: 'get only the recent errors'
                methods: ['GET']
                handler: ([query,uuid], request, response, statusCode = 200) -> 

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

            '/hubs/:uuid:/cache': 

                description: 'get output from a serailization of the traversal cache'
                methods: ['GET']
                handler: ([query,uuid], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.hubs[uuid]
                    notifier = local.hubContext.hubs[uuid]
                    local.respond( 
                        notifier.serialize(2).cache
                        statusCode
                        response
                    )

            '/hubs/:uuid:/cache/**/*': 

                description: 'get nested subkey from the cache tree'
                methods: ['GET'] #, 'POST'] #, 'DELETE']
                handler: ([query,uuid,deeper], request, response, statusCode = 200) -> 

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


            '/hubs/:uuid:/tools': 

                description: 'get output from a serailization of the tools tree'
                methods: ['GET']
                handler: recursor local, 'tools'

            '/hubs/:uuid:/tools/**/*': 

                description: 'get nested subkey from the tools key'
                methods: ['GET'] #, ['?PUT?', '?POST?']
                handler: recursor local, 'tools' 


            # '/hubs/:uuid:/clients': 

            #     description: 'pending'
            #     methods: ['GET']
            #     handler: ([query,uuid], request, response, statusCode = 200) -> 

            #         return local.methodNotAllowed response unless request.method == 'GET'
            #         return local.objectNotFound response unless local.hubContext.hubs[uuid]
            #         notifier = local.hubContext.hubs[uuid]
            #         local.respond( 
            #             'PENDING'
            #             statusCode
            #             response
            #         )


            '/hubs/:uuid:/middlewares': 

                description: 'get only the middlewares'
                methods: ['GET', 'POST']
                accepts: ['text/javascript', 'text/coffeescript']
                handler: ([query,hubuuid,nothing,authenticEntity], {method, headers, body}, response, statusCode = 200) -> 

                    if method == 'POST'
                        return local.objectNotFound response unless local.hubContext.hubs[hubuuid]
                        notifier = local.hubContext.hubs[hubuuid]
                        return local.middleware 'insert', notifier, null, headers['content-type'], body, response, statusCode

                    return local.methodNotAllowed response unless method == 'GET'
                    return local.objectNotFound response unless local.hubContext.hubs[hubuuid]
                    notifier = local.hubContext.hubs[hubuuid]
                    local.respond(
                        notifier.serialize(2).middlewares
                        statusCode
                        response
                    )


            '/hubs/:uuid:/middlewares/:slot:':

                description: 'get or update or delete a middleware'
                methods: ['GET', 'PUT', 'POST'] # , 'DELETE']
                accepts: ['text/javascript', 'text/coffeescript']
                handler: ([query,hubuuid,slot,authenticEntity], {method, headers, body}, response, statusCode = 200) -> 

                    if method == 'POST' or method == 'PUT'
                        return local.objectNotFound response unless local.hubContext.hubs[hubuuid]
                        notifier = local.hubContext.hubs[hubuuid]
                        return local.middleware 'upsert', notifier, slot, headers['content-type'], body, response, statusCode

                    return local.methodNotAllowed response unless method == 'GET'
                    return local.objectNotFound response unless local.hubContext.hubs[hubuuid]

                    notifier = local.hubContext.hubs[hubuuid]
                    middlewares = notifier.serialize(2).middlewares
                    try return local.respond middlewares[slot], statusCode, response
                    objectNotFound response


            '/hubs/:uuid:/middlewares/:slot:/fn':
                description: 'show middleware function'
                methods: ['GET']
                handler: ([query,uuid,slot,authenticEntity], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.hubs[uuid]

                    notifier = local.hubContext.hubs[uuid]
                    middlewares = notifier.serialize(2).middlewares
                    if middlewares[slot]
                        fnString = middlewares[slot].fn.toString()
                        response.writeHead 200,
                            'Content-Type': 'text/javascript'
                            'Content-Length': fnString.length
                        return response.end fnString
                    objectNotFound response


            '/hubs/:uuid:/middlewares/:slot:/disable':
                description: 'disable a middleware'
                methods: ['GET']
                handler: ([query,uuid,slot,authenticEntity], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.hubs[uuid]

                    notifier = local.hubContext.hubs[uuid]
                    notifier.use slot: slot, enabled: false, update: true
                    middlewares = notifier.serialize(2).middlewares
                    return local.respond  middlewares[slot], statusCode, response
                    objectNotFound response


            '/hubs/:uuid:/middlewares/:slot:/enable':
                description: 'enable a middleware'
                methods: ['GET']
                handler: ([query,uuid,slot,authenticEntity], request, response, statusCode = 200) -> 

                    return local.methodNotAllowed response unless request.method == 'GET'
                    return local.objectNotFound response unless local.hubContext.hubs[uuid]

                    notifier = local.hubContext.hubs[uuid]
                    notifier.use slot: slot, enabled: true, update: true
                    middlewares = notifier.serialize(2).middlewares
                    return local.respond  middlewares[slot], statusCode, response
                    objectNotFound response


            # '/hubs/:uuid:/middlewares/:title:/replace':
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
        ##   of notable size, and the posibility that a $notice api plugin might ALSO prefer:
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
            # * $notice api function could be provided with the request's EventEmitter
            #       * complexity arises on the question around who makes the response
            #       * which is what makes the connect stack such a masterstroke, 
            #       * makes that a question of sequence, 
            #       * early bird gets the wormhole,
            #       * and closes it.
            # * ?ways? for a $notice apiFunction to inform this decoder not to load
            #          an inbound stream into memory
            #
            # * and the path
            # * and the headers
            #  

            request.body = body
            path = request.url
            try [match,path,query] = path.match /(.*)\?(.*)/

            #
            # aliases
            # -------
            # 
            # /hub/1 == /hubs/1
            # /hub   (ignored)
            # /hub/1/middleware/1 == /hub/1/middlewares/1
            # /hub/1/middleware (ignored)
            # /hub/1/mwares       == /hubs/1/middlewares
            # /hub/1/mware/1      == /hubs/1/middlewares/1
            # /hub/1/mware      (ignored)
            #
            
            # path = path.replace /\/hub\//, '/hubs/'
            # path = path.replace /\/middleware\//, '/middlewares/'
            # path = path.replace /\/mwares/, '/middlewares'
            # path = path.replace /\/mware\//, '/middlewares/'

            if path == '/about' or path == '/'
                return local.routes["/about"].handler [], request, response
                
            if path[-1..] == '/' then path = path[0..-2]

            try 
                [match, base, uuid, nested, slot, action] = path.match /(.*)\/(.*)\/(.*)\/(.*)\/(.*)/
                return local.routes["#{base}/:uuid:/#{nested}/:slot:/#{action}"].handler [query, uuid, slot, authenticEntity], request, response
            try
                [match, base, uuid, nested, slot] = path.match /(.*)\/(.*)\/(.*)\/(.*)/
                return local.routes["#{base}/:uuid:/#{nested}/:slot:"].handler [query, uuid, slot, authenticEntity], request, response
            try
                [match, base, uuid, nested] = path.match /(.*)\/(.*)\/(.*)/
                
                try if [match, uuid, deeper] = path.match /\/hubs\/(.*)\/cache\/(.*)/
                    return local.routes["/hubs/:uuid:/cache/**/*"].handler [query, uuid, deeper], request, response
                
                try if [match, uuid, deeper] = path.match /\/hubs\/(.*)\/tools\/(.*)/
                    return local.routes["/hubs/:uuid:/tools/**/*"].handler [query, uuid, deeper, authenticEntity], request, response

                return local.routes["#{base}/:uuid:/#{nested}"].handler [query, uuid], request, response
            try
                [match, base, uuid] = path.match /\/(.*)\/(.*)/
                return local.routes["/#{base}/:uuid:"].handler [query, uuid], request, response
            try
                [match, base] = path.match /\/(.*)/
                return local.routes["/#{base}"].handler [query], request, response

            #
            # TODO: Confirm restify can do all the necessaries here. And switch.
            #

            return local.objectNotFound response

    server.listen port, address, -> 
        {address, port} = server.address()
        console.log 'API @ %s://%s:%s', 
            transport, address, port


    return api = 
        register: local.register

