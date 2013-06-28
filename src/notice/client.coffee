connector   = require './connector'
notifier    = require './notifier'

onConnected = (title, opts, uplink, callback) -> 

    #
    # connected to the hub, create a notifier and 
    # assign pipeline final middleware ....
    #
    
    notice = notifier.create title

    notice.first = (msg, next) -> 

        msg.direction = 'out'
        next()


    notice.last = (msg, next) -> 

        console.log 'sending message:', JSON.stringify msg.content, null, 2

        if msg.direction == 'out'

            type = msg.context.type
            uplink.emit type, msg.context, msg

        next()


    callback null, notice


module.exports = 

    connect: (title, opts, callback) -> 

        connector.connect

            loglevel:  opts.connect.loglevel
            secret:    opts.connect.secret
            transport: opts.connect.transport
            address:   opts.connect.address
            port:      opts.connect.port

            (error, uplink) -> 

                return callback error if error?
                onConnected title, opts, uplink, callback
