{hostname} = require 'os'
{deferred} = require 'also'
notifier   = require '../notifier'
Connector  = require './connector'
{
    terminal
    reservedCapsule
    undefinedArg
    alreadyDefined
    connectRejected
    disconnected
} = require '../errors'


testable               = undefined
module.exports._client = -> testable
module.exports.client  = (config = {}) ->

    for type of config.capsules

        throw reservedCapsule type if type.match(
            /^connect$|^handshake$|^accept$|^reject$|^disconnect$|^resume$|^capsule$|^error$/
        )


    testable = local = 

        Notifier: notifier.notifier config
        clients:  {}

        create: deferred ({reject, resolve, notify}, originName, opts = {}, callback) -> 
            
            try 

                throw undefinedArg 'originName' unless typeof originName is 'string'
                throw alreadyDefined 'originName', originName if local.clients[originName]?
                throw undefinedArg 'opts.connect.port' unless opts.connect? and typeof opts.connect.port is 'number'
                
                client = local.Notifier.create originName
                local.clients[originName] = client

            catch error

                return terminal error, reject, callback


            opts.context ||= {}
            opts.context.hostname = hostname()
            opts.context.pid      = process.pid


            socket = Connector.connect opts.connect

            client.connection       ||= {}
            client.connection.state   = 'pending'
            client.connection.stateAt = Date.now()
            already = false 


            #
            # #DUPLICATE1
            # 
            # subscribe inbound handlers for all configured capsules
            # ------------------------------------------------------
            # 
            # TODO: set capsule.inbound
            # 

            for type of config.capsules

                    #
                    # * control capsules are local only
                    #  

                continue if type == 'control'
                do (type) -> 

                    #
                    # * all other capsules are proxied into the local 
                    #   middleware pipeline (hub) 
                    #

                    socket.on type, (payload) -> 

                        unless typeof client[type] == 'function'

                            # 
                            # * client and hub should use a common capsules config
                            # 

                            process.stderr.write "notice undefined capsule type '#{type}'"
                            return

                        #
                        # * proxy the inbound capsules onto the middleware pipeline
                        # TODO: typeValue, protected, hidden, watched
                        # 

                        client[type] payload


            #
            # final middleware on the local bus transfers capsule onto socket 
            # ---------------------------------------------------------------
            # 
            # * Notifications generated localy traverse the local middleware
            #   first.
            # 
            # * If they reach the end of the pipeline they are transferred
            #   onto the hub-bound socket AND called back to the original 
            #   capsule creator.
            # 
            # * later, capsule.boomerang makes this final middleware not
            #          callback to the creator until the capsule returns 
            #          from the netork     
            #
            #    boomerang may become the default configuration later 
            # 

            #
            # * the capsule is popped off the tail of the local
            #   middleware pipeline after the hub acks the capsule
            # 
            # * use the promise notify() call to inform the capsule origin
            #   of the capsule being sent.
            #   
            #   Unfortunately a capsule origin with a node style callback
            #   waiting has no concrete facility to receive this information
            #   and will remain in the dark until the hub ack.
            #         


            version  = 1    # protocol version
                            # TODO: version into handshake
            sequence = 0


            client.use

                title: 'outbound socket interface'
                last:  true
                (next, capsule) -> 

                    ### grep PROTOCOL1 encode ###

                    #
                    # TODO: is socket connected?
                    #       what happens when sending on not 
                    #
                    sequence++
                    header = [version, sequence]

                    #
                    # TODO: much room for optimization here
                    # TODO: move this into {protocol}.encode
                    # 

                    control = 
                        type:      capsule._type
                        uuid:      capsule._uuid
                        protected: capsule._protected
                        hidden:    capsule._hidden

                        #?
                        #? TODO: is maintaining the watched property callback
                        #?       link even after emitting the capsule a poss-
                        #?       ibility?
                        #?
                        #?       would doing so provide __ACTUAL_VALUE__
                        #?
                        #?       what if the destination emits it again, even
                        #?       further
                        #?
                        #?       what if some portion of the capsules lifetime
                        #?       is spent on the other side of a tightened fi-
                        #?       rewall
                        #?
                        #?       (preventing certain easy solutions)
                        #?
                        #?       breadcrumbs didn't work for hansel and getel
                        #?
                        #?       are there birds in the fiber
                        #?

                    socket.emit 'capsule', header, control, capsule.all
                    next()




            socket.on 'connect', -> 
                if client.connection.state == 'interrupted'

                    #
                    # previously fully established connection has resumed
                    # ---------------------------------------------------
                    # 
                    # * It is possible the server still has reference to
                    #   this client context so this sends a resume event
                    #   but includes all handshake data incase the server
                    #   has lost all notion. 
                    #

                    client.connection.state   = 'resuming'
                    client.connection.stateAt = Date.now()
                    socket.emit 'resume', originName, opts.connect.secret || '', opts.context || {}

                    #
                    # * server will respond with 'accept' on success, or disconnect()
                    #

                    #
                    # TODO: inform resumed onto the local middleware 
                    #

                    return

                client.connection.state   = 'connecting'
                client.connection.stateAt = Date.now()
                socket.emit 'handshake', originName, opts.connect.secret || '', opts.context || {}

                #
                # * server will respond with 'accept' on success, or disconnect()
                #


            socket.on 'accept', -> 
                if client.connection.state == 'resuming'

                    #
                    # the resuming client has been accepted
                    # -------------------------------------
                    # 
                    # * This does not callback with the newly connected client,
                    #   that callback only occurs on the first connect
                    #

                    #
                    # TODO: inform resumed onto the local middleware 
                    # TODO: hub context
                    # 

                    client.connection.state   = 'accepted'
                    client.connection.stateAt = Date.now()
                    client.connection.interruptions ||= count: 0
                    client.connection.interruptions.count++
                    return 

                #
                # TODO: hub context
                # 

                client.connection.state   = 'accepted'
                client.connection.stateAt = Date.now()
                resolve client
                if typeof callback == 'function' then callback null, client


            socket.on 'reject', (rejection) -> 

                ### it may happen that the disconnect occurs before the reject, making the rejection reason 'vanish' ###

                terminal connectRejected(originName, rejection), reject, callback
                already = true

            socket.on 'disconnect', -> 
                unless client.connection.state == 'accepted'

                    #
                    # the connection was never fully established
                    # ------------------------------------------
                    #
                    # TODO: notifier.destroy originName (another one in on 'error' below)
                    #       (it will still be present in the collection there)
                    #
                    # TODO: formalize errors 
                    #       (this following is horrible)
                    # 

                    delete local.clients[originName]
                    terminal disconnected(originName), reject, callback unless already
                    already = true
                    return 
                
                #
                # fully established connection has been lost
                # ------------------------------------------
                #

                client.connection.state   = 'interrupted'
                client.connection.stateAt = Date.now()
                return

                #
                # TODO: inform interrupted onto the local middleware 
                #



            socket.on 'error', (error) -> 
                unless client.connection? and client.connection.state == 'pending'
                    
                    #
                    # TODO: handle error after connect|accept
                    #

                    console.log 'TODO: handle socket error after connect|accept'
                    console.log error
                    return


                delete local.clients[originName]
                setTimeout (-> 

                    # 
                    # `opts.connect.errorWait`
                    # 
                    # * Incase something is managing the process that exited because no 
                    #   connection was made in such a way that it enters a tight respawn 
                    #   loop effectively creating a potentially dangerous SYN flood
                    # 

                    reject error
                    if typeof callback == 'function' 
                        callback error unless already
                        already = true

                ), opts.connect.errorWait or 2000
                return

                # #
                # # `opts.connect.retryWait`
                # # 
                # # * OVERRIDES `opts.connect.errorWait`
                # # 
                # # * Incase it is preferrable for the connection to be retried indefinately
                # # * IMPORTANT: The callback only occurs after connection, so this will leave
                # #              the caller of Notice.client waiting... (possibly a long time)
                # # * RECOMMEND: Do not using this in high frequency scheduled jobs.
                # # 

                # if opts.connect.retryWait? # and opts.connect.retryWait > 9999

                #     client.connection.state            = 'retrying'
                #     client.connection.retryStartedAt ||= Date.now()
                #     client.connection.retryCount      ?= -1
                #     client.connection.retryCount++
                #     client.connection.stateAt          = Date.now()
                #     console.log RETRY: client.connection
                #     return


                # opts.connect.retryWait = 0 # ignore crazy retryWait milliseconds
                # error = new Error "Client.create( '#{originName}', opts ) failed connect"
                # reject error
                # if typeof callback == 'function' then callback error



            


    return api = 
        create: local.create

















return 
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
                    #       - no point in sending the origin on each capsule
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
                        #         (this is inbound to client capsule)
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
        #   local middleware can ammend this capsule before it gets emitted
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

            origin:       opts.origin

            onAssign:     client.onAssign
            onConnect:    client.onConnect
            onReconnect:  client.onReconnect
            onDisconnect: client.onDisconnect

            callback

