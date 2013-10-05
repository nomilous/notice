Testable            = undefined
testable            = undefined
module.exports._Handler = -> Testable
module.exports._handler = -> testable
module.exports.handler  = (config = {}) ->

    Testable = Handler =

        create: (hubName, hubContext, opts) -> 

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

                        



                        id = socket.id

                        if previousID = hubContext.name2id[originName]

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

                                socket.emit 'reject', 
                                    reason: 'already connected'
                                    hostname: client.context.hostname
                                    pid: client.context.pid

                                socket.disconnect()
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
                            handler.accept socket, client, originName, context
                            return


                        client = 
                            title:   originName
                            context: context
                            hub:     hubName
                            socket:  socket

                        handler.accept socket, client, originName, context


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



                        id = socket.id

                        if previousID = hubContext.name2id[originName]
                            client = hubContext.clients[previousID]
                            delete hubContext.clients[previousID]
                            delete hubContext.name2id[originName]
                            hubContext.clients[id] = client

                        else 
                            hubContext.clients[socket.id] = client = 
                                title:   originName
                                context: context
                                hub:     hubName


                        handler.accept socket, client, originName, context



                accept: (socket, client, originName, context) ->

                    id = socket.id
                    hubContext.clients[id] = client
                    client.connected ||= {}
                    client.connected.state    = 'connected'
                    client.connected.stateAt  = Date.now()
                    client.context.hostname   = context.hostname
                    client.context.pid        = context.pid
                    hubContext.name2id[originName] = id
                    socket.emit 'accept'
                    hubContext.connections()


                reject: (socket, details) -> 

                    socket.emit 'reject', details
                    socket.disconnect()
                    return


    return api = 
        create: Handler.create
