module.exports.authenticator = (config = {}) -> 

    authenticateFn = try config.manager.authenticate

    requestAuth = (response) -> 

        response.writeHead 401, 

            #
            # * this should prompt most browsers to popup 
            #   their builtin login dialog
            #

            'www-authenticate': 'BASIC' #  realm="..."'

        response.end()

    decodeAuth = (authorization, request, response) -> 

        #
        # how to decode the basic auth string
        # -----------------------------------
        # 
        # * thanks Mark :) https://github.com/mcavage/node-restify/blob/master/lib/plugins/authorization.js#L34
        #

        try 

            decoded = new Buffer(authorization, 'base64').toString 'utf8'
            [input, username, password] = decoded.match /(.*):(.*)/
            
            username: username
            password: password

        catch error

            #
            # * decode failed, respond again with 401 and auth request
            #

            requestAuth response


    (requestHandler) -> (request, response) -> 


        try authorization = request.headers.authorization
        return requestAuth response unless authorization? 
        return unless {username, password} = decodeAuth authorization, request, response

        authenticateFn username, password, (error, result) -> 

            #
            # * call the actual requestHandler
            #

            requestHandler request, response

