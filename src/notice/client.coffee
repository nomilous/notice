{deferred} = require 'also'
notifier   = require './notifier'
Connector  = require './connector'

testable               = undefined
module.exports._client = -> testable
module.exports.client  = (config = {}) ->

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

            socket = Connector.connect opts.connect

            client.connection = 
                state:  'pending'
                stateAt: Date.now()

            socket.on 'connect', -> 
                client.connection.state   = 'connected'
                client.connection.stateAt = Date.now()
                socket.emit 'handshake', clientName, opts.connect.secret || '', opts.context || {}

            socket.on 'accept', -> 
                client.connection.state   = 'accepted'
                client.connection.stateAt = Date.now()
                resolve client
                if typeof callback == 'function' then callback null, client


            socket.on 'disconnect', -> 
                unless client.connection? and client.connection.state == 'accepted'

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
                    if typeof callback == 'function' then callback error
                    return
                
                #
                # TODO: handle 'connection might resume', server may have restarted
                #

                console.log lost: 1


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
                    if typeof callback == 'function' then callback error
                    
                ), opts.connect.errorWait or 2000



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

