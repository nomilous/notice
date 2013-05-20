handler        = undefined
module.exports = config = (opts = {}) ->

    if typeof opts.handler == 'undefined'

        #
        # config did not specify handler
        #

        handler = require './default_handler'

    else

        handler = opts.handler
    

Object.defineProperty config, 'handler',

    get: -> handler

