connector = require './connector'

module.exports = 

    connect: (title, opts, callback) -> 

        connector.connect

            transport: opts.uplink.transport
            address: opts.uplink.address
            port: opts.uplink.port

            (error, uplink) -> 

                return callback error if error?

                console.log 'connected', uplink.socket.sessionid
                callback null, notice: 'CLIENT'
        
