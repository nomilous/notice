connector   = require './connector'
notifier    = require './notifier'
{defer}     = require 'when'

createClient = (title, opts) -> 
    
    notice = notifier.create title

    onAssign: ({socket}) -> 

        #
        # * assign socket to notifier
        # * return promise that resolves with the assigned notifier
        #

        assigning = defer()

        process.nextTick ->

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
                    socket.emit type, msg.context, msg

                next()


            for event in ['info', 'event']

                do (event) -> 

                    #
                    # inbound event from the socket are directed into
                    # the middleware pipeline
                    #

                    socket.on event, (context, msg) -> 

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

            assigning.resolve notice


        assigning.promise


    onConnect: ({socket}) ->

        #
        # * notifier is assigned and handshake is complete
        # * returns promise
        # 

        return notice.event 'connect'


    onReconnect: ({socket}) -> 

        #
        # * emit reconnect notification down the pipeline, the implementations
        #   local middleware can ammend this message before it gets emitted
        #   hubward
        # * returns promise
        #

        return notice.event 'reconnect'


    onDisconnect: ({socket}) -> 

        #
        # * this event is primary for local middlewares, it may or may not reach
        #   the other side of the socket (which has just disconnected, but may have 
        #   re-established by the time the local pipeline traversal is complete)
        # * return promsie
        # 

        return notice.event 'disconnect'


module.exports = 

    connect: (title, opts, callback) -> 

        client = createClient title, opts

        connector.connect

            loglevel:     opts.connect.loglevel
            secret:       opts.connect.secret
            transport:    opts.connect.transport
            address:      opts.connect.address
            port:         opts.connect.port

            #
            # * origin context
            # * sent on handshake
            #

            origin:       opts.client

            onAssign:     client.onAssign
            onConnect:    client.onConnect
            onReconnect:  client.onReconnect
            onDisconnect: client.onDisconnect

            callback

