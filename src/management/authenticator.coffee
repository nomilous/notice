module.exports.authenticator = (config = {}) -> 

    authenticateFn = try config.manager.authenticate

    (requestHandler) -> (request, response) -> 

        try authorization = request.headers.authorization
        unless authorization? 

            #
            # no authorization in header
            # --------------------------
            #

            response.writeHead 401, 

                #
                # * this should prompt most browsers to popup 
                #   their builtin login dialog
                #

                'www-authenticate': 'BASIC' #  realm="..."'

            return response.end()

        #
        # * right ...how to decode the basic auth string??
        #

        authenticateFn()

        #
        # * call the actual requestHandler
        #

        requestHandler request, response

