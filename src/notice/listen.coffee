http      = require 'http'
https     = require 'https'
fs        = require 'fs'
socketio  = require 'socket.io'
transport = 'http'

start = (opts) -> 
    
    if opts.cert? and opts.key? 

        try

            transport = 'https'
            return https.createServer

                key:  fs.readFileSync opts.key
                cert: fs.readFileSync opts.cert

        catch error

            console.log error

            transport = 'http'

    http.createServer()

module.exports = (opts = {}) -> 

    opts.port  ||=  10001
    opts.iface ||= 'localhost'
    

    #
    # create server unless provided and bind socket.io
    #

    server = opts.server || start opts
    io     = socketio.listen server
    io.configure -> io.set 'log level', opts.loglevel || 1


    #
    # start server
    #

    unless opts.server?

        server.listen opts.port, opts.iface, -> 

            {address, port} = server.address()
            console.log 'listening @ %s://%s:%s', 
                transport, address, port

    return io

