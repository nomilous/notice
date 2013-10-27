
ioclient = require 'socket.io-client'

module.exports.connect = (opts) -> 

    #
    # TODO: adaptor plugin ability
    #       capacity for more that one inprocess client
    #
    
    # opts.adaptor ||= 'socket.io'
    # opts.url     ||= 'https://localhost'

    if opts.rejectUnauthorized?
        require('https').globalAgent.options.rejectUnauthorized = opts.rejectUnauthorized

    ioclient.connect opts.url
