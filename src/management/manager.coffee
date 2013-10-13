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

        register: (hubContext) -> 

        routes: 

            '/about': 

                description: 'show this'
                handler: (request, response, statusCode = 200) -> 

                    body = JSON.stringify 

                        module:  'notice'
                        version: version
                        # TODO_LINK
                        doc: 'https://github.com/nomilous/notice/tree/develop/spec/management'
                        endpoints: local.routes

                        #
                        # pretty for now
                        #

                        null
                        2

                    response.writeHead statusCode,
                        'Content-Type': 'application/json'
                        'Content-Length': body.length

                    response.write body
                    response.end()






    port         = listen.port
    address      = if listen.hostname? then listen.hostname else '127.0.0.1'
    opts         = {}
    opts.key     = listen.key
    opts.cert    = listen.cert

    {server, transport} = start opts, local.requestHandler = authenticated (request, response) ->

        path = request.url

        unless local.routes[path]? 

            #
            # request for undefined route, respond 404 (but with help)
            #

            return local.routes['/about'].handler request, response, 404 

        local.routes[path].handler request, response



    server.listen port, address, -> 
        {address, port} = server.address()
        console.log 'API @ %s://%s:%s', 
            transport, address, port


    return api = 
        register: local.register

