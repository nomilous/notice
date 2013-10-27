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


                console.log BEFORE: fn.toString().match( /(\$\$)/ )[1]

                body = body.replace /\"__SUBSTITUTE_THE_FUNCTION__\"/, fn.toString()

                #
                # $all is converted to $all in the previous statement! (um.,  HOW!)
                #
                
                console.log AFTER: body.match( /(\$\$)/ )[1]

                req.body = body
                req.headers ||= {}  # todo: dinkum should do this
                console.log BBB: body
                req.headers['content-type'] = 'text/javascript'
