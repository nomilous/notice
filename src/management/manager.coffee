{authenticator} = require './authenticator'

testable               = undefined
module.exports._manager = -> testable
module.exports.manager  = (config = {}) ->

    listen       = config.manage.listen
    authenticate = authenticator config
    
    server = require('http').createServer()


    testable = local = {}