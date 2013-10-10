
ioclient = require 'socket.io-client'

module.exports.connect = (opts) -> 

    #
    # TODO: adaptor plugin ability
    #
    
    # opts.adaptor ||= 'socket.io'
    # opts.url     ||= 'https://localhost'

    if opts.rejectUnauthorized?
        require('https').globalAgent.options.rejectUnauthorized = opts.rejectUnauthorized

    ioclient.connect opts.url
