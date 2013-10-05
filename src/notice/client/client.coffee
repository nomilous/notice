{deferred} = require 'also'
notifier   = require '../notifier'
Connector  = require './connector'
{hostname} = require 'os'

testable               = undefined
module.exports._client = -> testable
module.exports.client  = (config = {}) ->


    for type of config.messages

        throw new Error(
            "notice: '#{type}' is a reserved message type." 
        ) if type.match /connect|handshake|accept|reject|disconnect|resume|error/

    testable = local = 

        Notifier: notifier.notifier config

        clients: {}

        create: deferred ({reject, resolve, notify}, clientName, opts = {}, callback) -> 

            unless typeof clientName is 'string'
                error = new Error 'Client.create( clientName, opts ) requires clientName as string'
                reject error
                if typeof callback == 'function' then callback error
                return

            if local.clients[clientName]?
                error = new Error "Client.create( '#{clientName}', opts ) is already defined"
                reject error
                if typeof callback == 'function' then callback error
                return

            unless opts.connect? and typeof opts.connect.port == 'number'
                error = new Error "Client.create( '#{clientName}', opts ) requires opts.connect.port"
                reject error
                if typeof callback == 'function' then callback error
                return


            try client = local.clients[clientName] = local.Notifier.create clientName
            catch error
                reject error
                if typeof callback == 'function' then callback error
                return



            opts.context ||= {}
            opts.context.hostname = hostname()
            opts.context.pid      = process.pid

            socket = undefined
            connect = -> 

                socket = Connector.connect opts.connect

                client.connection       ||= {}
                client.connection.state   = 'pending'
                client.connection.stateAt = Date.now()

                already = false 

                # 
                # TEMPORARY
                #

                setTimeout (->
                    socket.emit 'event', event: 'eventname', pay: 'load'
                    socket.emit 'undefined', pay: 'load'
                ), 1000


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
                        socket.emit 'resume', clientName, opts.connect.secret || '', opts.context || {}

                        #
                        # * server will respond with 'accept' on success, or disconnect()
                        #

                        #
                        # TODO: inform resumed onto the local middleware 
                        #

                        return

                    client.connection.state   = 'connecting'
                    client.connection.stateAt = Date.now()
                    socket.emit 'handshake', clientName, opts.connect.secret || '', opts.context || {}

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
                        #

                        client.connection.state   = 'accepted'
                        client.connection.stateAt = Date.now()
                        client.connection.interruptions ||= count: 0
                        client.connection.interruptions.count++
                        return 

                    client.connection.state   = 'accepted'
                    client.connection.stateAt = Date.now()
                    resolve client
                    if typeof callback == 'function' then callback null, client


                socket.on 'reject', (rejection) -> 

                    error = new Error "notice '#{clientName}' rejected - #{rejection.reason} from #{rejection.pid}.#{rejection.hostname}"
                    reject error
                    if typeof callback == 'function' 
                        callback error unless already
                        already = true


                socket.on 'disconnect', -> 
                    unless client.connection.state == 'accepted'

                        #
                        # the connection was never fully established
                        # ------------------------------------------
                        #
                        # TODO: notifier.destroy clientName (another one in on 'error' below)
                        #       (it will still be present in the collection there)
                        #
                        # TODO: formalize errors 
                        #       (this following is horrible)
                        # 

                        delete local.clients[clientName]
                        error = new Error "Client.create( '#{clientName}', opts ) failed connect or bad secret"
                        reject error
                        if typeof callback == 'function' 
                            callback error unless already
                            already = true
                        return
                    
                    #
                    # fully established connection has been lost
                    # ------------------------------------------
                    #

                    client.connection.state   = 'interrupted'
                    client.connection.stateAt = Date.now()

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


                    delete local.clients[clientName]
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
                    # error = new Error "Client.create( '#{clientName}', opts ) failed connect"
                    # reject error
                    # if typeof callback == 'function' then callback error


            connect()
            


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

            origin:       opts.origin

            onAssign:     client.onAssign
            onConnect:    client.onConnect
            onReconnect:  client.onReconnect
            onDisconnect: client.onDisconnect

            callback

