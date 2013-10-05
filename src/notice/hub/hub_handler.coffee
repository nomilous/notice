Testable            = undefined
testable            = undefined
module.exports._Handler = -> Testable
module.exports._handler = -> testable
module.exports.handler  = (config = {}) ->

    Testable = Handler =

        create: (hubName, hubNotifier, hubContext, opts) -> 

            testable = handler = 

                disconnect: (socket) -> 

                    ->

                        id = socket.id
                        try client = hubContext.clients[id]
                        return unless client?

                        client.connected.state    = 'disconnected'
                        client.connected.stateAt  = Date.now()
                        hubContext.connections()  



                handshake: (socket) -> 

                    (originName, secret, context) -> 

                        unless secret == opts.listen.secret

                            return handler.reject socket, reason: 'bad secret' 


                        #
                        # remote client is making it's first connection
                        # ---------------------------------------------
                        #
                        # * the client is a new process
                        # * it may have been previously connected (and was restarted)
                        #   in which case there may already be local reference to it.
                        # 

                        if previousID = hubContext.name2id[originName]

                            return handler.handleExisting socket, previousID, originName, context
                            
                        return handler.handleNew socket, originName, context


                resume: (socket) -> 

                    (originName, secret, context) -> 

                        unless secret == opts.listen.secret

                            return handler.reject socket, reason: 'bad secret' 


                        #
                        # remote client is resuming an interrupted connection
                        # ---------------------------------------------------
                        #
                        # * the client process was previously connected
                        # * this server may have been restarted / upgraded
                        # 

                        #
                        # identical to on connect (for now)
                        #

                        if previousID = hubContext.name2id[originName]

                            return handler.handleExisting socket, previousID, originName, context 

                        return handler.handleNew socket, originName, context



                accept: (newSocket, existingClient, originName, newContext) ->

                    id = newSocket.id
                    hubContext.clients[id] = existingClient
                    existingClient.connected ||= {}
                    existingClient.connected.state    = 'connected'
                    existingClient.connected.stateAt  = Date.now()

                    #
                    # TODO: context as capsule with watched properties
                    # TODO: store context (persistance plugin) to enable
                    #       client attach to different server and resume
                    #       on previous accumulated state
                    # 

                    for key of newContext
                        existingClient.context[key] = newContext[key]
                    
                    hubContext.name2id[originName] = id
                    newSocket.emit 'accept'
                    hubContext.connections()


                reject: (socket, details) -> 

                    socket.emit 'reject', details
                    socket.disconnect()
                    return


                handleNew: (socket, originName, context) ->

                    client = 
                        title:   originName
                        context: context
                        hub:     hubName
                        socket:  socket

                    handler.accept socket, client, originName, context


                handleExisting: (newSocket, previousID, originName, newContext) -> 

                    client = hubContext.clients[previousID]

                    if client.connected.state == 'connected'

                        #
                        # first client with this originName is still 
                        # connected... do not allow new connection.
                        #
                        # TODO: make this configurable
                        #       - keep new and kill old
                        #       - confirm old before rejecting new
                        #             -- by probe
                        #             -- by last activity age
                        #             BAD if rejecting new when old is broken
                        #       - ??? keep both
                        # 

                        newSocket.emit 'reject',

                            reason: 'already connected'
                            hostname: client.context.hostname
                            pid: client.context.pid

                        newSocket.disconnect()
                        hubContext.connections()
                        return


                    #
                    # * got previous reference of this client...
                    # * TODO: make performing a compariton of old and new 
                    #         context a posibility, probably down the pipeline
                    # 
                    # * FOR NOW the old context is kept and new is ignored
                    #   =======
                    # 

                    delete hubContext.clients[previousID]
                    delete hubContext.name2id[originName]
                    handler.accept newSocket, client, originName, newContext


    return api = 
        create: Handler.create
