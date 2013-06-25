connector   = require './connector'
notifier    = require './notifier'

onConnected = (title, opts, uplink, callback) -> 

    #
    # connected to the hub, create a notifier and 
    # assign pipeline final middleware ....
    #
    
    notice = notifier.create title

    notice.finally = (msg, next) -> 

        console.log 'sending message:', JSON.stringify msg.content, null, 2

        #
        # a notification has been generated,
        # transmit it over the socket
        #

        type = msg.context.type
        uplink.emit type, msg.content
        next()

    callback null, notice


module.exports = 

    connect: (title, opts, callback) -> 

        connector.connect

            secret:    opts.connect.secret
            transport: opts.connect.transport
            address:   opts.connect.address
            port:      opts.connect.port

            (error, uplink) -> 

                return callback error if error?
                onConnected title, opts, uplink, callback
