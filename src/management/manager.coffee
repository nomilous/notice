{authenticator} = require './authenticator'
{missingConfig} = require '../notice/errors'

testable               = undefined
module.exports._manager = -> testable
module.exports.manager  = (config = {}) ->

    try listen       = config.manager.listen
    try authenticate = authenticator config

    unless listen?
        throw missingConfig 'config.manager.listen', 'manage' 

    unless typeof listen.port is 'number'
        throw missingConfig 'config.manager.listen.port', 'manage' 


    transport = if listen.cert? and listen.key? then 'https' else 'http'
    hostname  = if listen.hostname? then listen.hostname else '127.0.0.1'
    port      = listen.port
    testable  = local = {}
    

    server = if transport == 'https' 

        try require( transport ).createServer()

    server ||= require('http').createServer()


    server.listen port, hostname, -> 
        {address, port} = server.address()
        console.log 'API @ %s://%s:%s', 
            transport, address, port

