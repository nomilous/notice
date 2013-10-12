module.exports.authenticator = (config = {}) -> 

    authenticateFn = try config.manager.authenticate

    (request, response) -> 

        authenticateFn()







