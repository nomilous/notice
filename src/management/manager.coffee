{authenticator} = require './authenticator'
{missingConfig} = require '../notice/errors'
{start}         = require '../notice/hub/listener'

testable               = undefined
module.exports._manager = -> testable
module.exports.manager  = (config = {}) ->

    try listen       = config.manager.listen
    authenticate = authenticator config

    unless listen?
        throw missingConfig 'config.manager.listen', 'manager' 

    unless typeof listen.port is 'number'
        throw missingConfig 'config.manager.listen.port', 'manager'


    testable = local = 

        register: (hubContext) -> 

            console.log hubContext

        routes: {}


    port         = listen.port
    address      = if listen.hostname? then listen.hostname else '127.0.0.1'
    opts         = {}
    opts.key     = listen.key
    opts.cert    = listen.cert

    {server, transport} = start opts, authenticate (request, response) ->

        response.writeHead 200
        response.end 'okgood'

    server.listen port, address, -> 
        {address, port} = server.address()
        console.log 'API @ %s://%s:%s', 
            transport, address, port


    return api = register: local.register