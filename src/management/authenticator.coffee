module.exports.authenticator = (config = {}) -> 

    authentic = try config.manager.authenticate

    requestAuth = (response) -> 

        response.writeHead 401, 

            #
            # * this should prompt most browsers to popup 
            #   their builtin login dialog
            #

            'www-authenticate': 'BASIC' #  realm="..."'

        response.end()

    decodeAuth = (authorization, response) -> 

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
        return unless {username, password} = decodeAuth authorization, response

        if typeof authentic is 'function'

            #
            # * use configured upstream authentication function
            #

            authentic username, password, (error, isAuthentic) -> 

                #
                # TODO: error properly?
                # 
                # * it re-requests auth on error or not isAuthentic
                # * otherwise it hands over to the original responder 
                # 

                return requestHandler request, response if isAuthentic is true
                requestAuth response

        #
        # * use 'hard'coded username and password in config
        #

        if username == authentic.username and password == authentic.password

            return requestHandler request, response

        #
        # no. try again!
        #

        requestAuth response
