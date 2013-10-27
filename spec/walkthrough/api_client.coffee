{Client}       = require 'dinkum'
module.exports = (port) -> return Client.create

    transport: 'http'
    port: port

    authenticator:
        module: 'basic_auth'
        username: 'Api Client Username'
        password: '∆'

    content:

        #
        # a custom media to encode middleware inserts/upserts
        #

        middleware: 
            encode: (req) -> 
                object = req.middleware
                fn = object.fn
                object.fn = '__SUBSTITUTE_THE_FUNCTION__'
                body = JSON.stringify object
                body = body.replace /\"__SUBSTITUTE_THE_FUNCTION__\"/, fn.toString()
                req.body = body
                req.headers ||= {}  # todo: dinkum should do this
                req.headers['content-type'] = 'text/javascript'
