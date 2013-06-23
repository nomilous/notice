connector = require './connector'

module.exports = 

    connect: (title, opts, callback) -> 

        connector.connect

            transport: opts.transport
            address: opts.address
            port: opts.port

            (error, socket) -> 

                if error?

                    console.log error
                    return callback error



                console.log 'connected', socket.id
                callback null, notice: 'CLIENT'
        
