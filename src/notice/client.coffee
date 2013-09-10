connector   = require './connector'
notifier    = require './notifier'

createClient = (title, opts) -> 

    #
    # connected to the hub, create a notifier and 
    # assign pipeline final middleware ....
    #
    
    notice = notifier.create title


    onConnected: (uplink, callback) -> 

        notice.first = (msg, next) -> 
            
            msg.direction = 'out'
            next()

        notice.last = (msg, next) -> 
            
            if msg.direction == 'out'

                #
                # TODO: strip context (it was/shouldBe sent on handshake)
                # 
                #       - some context should remain (title, type)
                #       - no point in sending the origin on each message
                #       - allows for much more context at no extra cost
                #       - keep in pending persistance layer in mind here
                #

                type = msg.context.type
                uplink.emit type, msg.context, msg

            next()


        for event in ['info', 'event']

            do (event) -> 

                #
                # inbound event from the socket are directed into
                # the middleware pipeline
                #

                uplink.on event, (context, msg) -> 

                    #
                    # TODO: reconstitute context (stripped from all but handshake)
                    #       
                    #       - assuming hub also provides its context to client
                    #         (this is inbound to client message)
                    #

                    msg.direction = 'in'
                    msg.origin    = context.origin
                    title         = context.title
                    tenor         = context.tenor

                    notice[event][tenor] title, msg


        callback null, notice


    onReconnected: ({socket}) -> 

        #
        # emit reconnect notification down the pipeline, the implementations
        # local middleware can ammend this message before it gets emitted
        # hubward
        #

        notice.event 'reconnect'


module.exports = 

    connect: (title, opts, callback) -> 

        client = createClient title, opts

        connector.connect

            loglevel:    opts.connect.loglevel
            secret:      opts.connect.secret
            transport:   opts.connect.transport
            address:     opts.connect.address
            port:        opts.connect.port

            onReconnect: client.onReconnected

            (error, uplink) -> 

                return callback error if error?
                client.onConnected uplink, callback
