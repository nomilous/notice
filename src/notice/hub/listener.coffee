http      = require 'http'
https     = require 'https'
fs        = require 'fs'
socketio  = require 'socket.io'
# transport = 'http'

module.exports.start = start = (opts, handler) -> 
    
    if opts.cert? and opts.key? 

        try

            transport = 'https'
            server = https.createServer

                key:  fs.readFileSync opts.key
                cert: fs.readFileSync opts.cert
                handler

            return server: server, transport: transport

        #catch error

    transport = 'http'
    server = http.createServer handler

    return server: server, transport: transport


module.exports.listen = (opts, callback) -> 

    opts         ||=  {}
    opts.port    ||=  null
    opts.address ||= 'localhost'
    

    #
    # create server unless provided and bind socket.io
    #

    {server, transport} = start opts unless opts.server?
    server ||= opts.server
    io       = socketio.listen server
    io.configure -> io.set 'log level', opts.loglevel || 1


    #
    # start server
    #

    unless opts.server?

        server.on 'error', (error) -> callback error

        server.listen opts.port, opts.address, -> 

            {address, port} = server.address()
            console.log 'HUB @ %s://%s:%s', 
                transport, address, port

            callback null, 

                transport: transport
                address: address
                port: port

    return io

