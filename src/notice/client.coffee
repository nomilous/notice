connector = require './connector'

module.exports = 

    connect: (title, opts, callback) -> 

        connector.connect

            secret:    opts.connect.secret
            transport: opts.connect.transport
            address:   opts.connect.address
            port:      opts.connect.port

            (error, uplink) -> 

                return callback error if error?

                console.log 'connected', uplink.socket.sessionid
                callback null, notice: 'CLIENT'
        
