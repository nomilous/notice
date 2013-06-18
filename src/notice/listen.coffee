http     = require 'http'
start    = -> http.createServer()

listen   = (opts = {}) -> 

    opts.listen          ||= {}
    opts.listen.port     ||=  10001
    opts.listen.iface    ||= 'localhost'
    

    #
    # create server unless provided
    #

    server = opts.server || start()


    #
    # start server
    #

    unless opts.server?

        server.listen opts.listen.port, opts.listen.iface,

            -> console.log 'listening', server.address()

    


module.exports = listen