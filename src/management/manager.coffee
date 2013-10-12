{authenticator} = require './authenticator'
{missingConfig} = require '../notice/errors'

testable               = undefined
module.exports._manager = -> testable
module.exports.manager  = (config = {}) ->

    listen       = config.manage.listen
    authenticate = authenticator config

    unless typeof listen.port is 'number'
        throw missingConfig('config.manage.port', 'manage') 

    testable = local = {}
    
    server = if listen.cert? and listen.key?

        try require('https').createServer()


    server ||= require('http').createServer ->


    server.listen listen.port

