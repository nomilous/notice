http      = require 'http'
https     = require 'https'
fs        = require 'fs'
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

listen   = (opts = {}) -> 

    opts.port     ||=  10001
    opts.iface    ||= 'localhost'
    

    #
    # create server unless provided
    #

    server = opts.server || start opts




    #
    # start server
    #

    unless opts.server?

        server.listen opts.port, opts.iface, -> 

            {address, port} = server.address()
            console.log 'listening @ %s://%s:%s', 
                transport, address, port

    


module.exports = listen