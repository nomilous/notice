PROTOCOL_VERSION = 1

Testable            = undefined
testable            = undefined
module.exports._Handler = -> Testable
module.exports._handler = -> testable
module.exports.handler  = (config = {}) ->

    #
    # TODO: this bypasses config of the capsule supercope, 
    #       not doing so becomes necessary later.
    #

    Capsule = require('../capsule/capsule').capsule()

    Testable = Handler =

        create: (hubName, hubNotifier, hubContext, opts) -> 

            hubNotifier.use 

                title: 'inbound socket interface'
                first:  true

                (next, capsule, traversal) -> 

                    next() unless id = capsule._socket_id
                    delete capsule._socket_id
                   
                    try 

                        client = hubContext.clients[id]
                        traversal.origin = client

                    next()



            testable = handler = 

                disconnect: (socket) -> 


                    #
                    # TODO: client requests disconnect, emit 'stop'
                    # * client disconnects without intending, emit 'suspend'
                    # TODO: suspended / stopped client is reaped, emit: 'terminate'
                    #

                    ->

                        id = socket.id
                        try client = hubContext.clients[id]
                        return unless client?

                        client.connection ||= {}
                        client.connection.state    = 'disconnected'
                        client.connection.stateAt  = Date.now()

                        #
                        # emit control 'suspend'
                        # ----------------------
                        #
                        # * does not wait for result
                        # * TODO: ensure this does not go to the client
                        # 

                        hubNotifier.$$control 'suspend', 
                            _socket_id: id


                capsule: (socket) -> 

                    ### grep PROTOCOL1 decode ###

                    id = socket.id
                    mismatch = false
                
                    (header, control, payload) -> 

                        [version] = header
                        uuid      = control.uuid

                        unless version == PROTOCOL_VERSION

                            # 
                            # protocol mismatch
                            # -----------------
                            # 
                            # * logged only once per remote client socket
                            # * could still spew if the clientside is in a tight respawn loop
                            # * see 
                            # 

                            try 
                                client = hubContext.clients[id]
                                who = "#{client.context.pid}.#{client.context.hostname}"

                            unless mismatch
                                process.stderr.write "notice: protocol mismatch - thishub:#{PROTOCOL_VERSION} client:#{version} #{who}\n" 
                                mismatch = true
                            
                            return socket.emit 'nak',
                                uuid: control.uuid
                                reason: 'protocol mismatch'
                                support: [PROTOCOL_VERSION]

                        socket.emit 'ack',
                            uuid: control.uuid


                        #
                        # re-assemble the capsule
                        # -----------------------
                        # 
                        # * assigns the capsule._uuid as generated at the origin
                        # * applies hidden and protected property setting as specified 
                        #   at the origin
                        #

                        #
                        # TODO: raw.control.type might may be extraneous
                        #

                        try tected  = control.protected
                        try hidden  = control.hidden

                        capsule = new Capsule uuid: uuid
                        for property of payload
                            assign = {}
                            assign[property] = payload[property]
                            assign.hidden    = true if hidden[property]
                            assign.protected = true if tected[property]
                            capsule.set assign

                        capsule._socket_id = id

                        hubNotifier.$$raw capsule


                handshake: (socket) -> 

                    (originTitle, secret, context) -> 

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

                        #
                        # TODO: consider letting the middleware if the client should
                        #       be accepted
                        #

                        if previousID = hubContext.name2id[originTitle]

                            return handler.handleExisting 'start', socket, previousID, originTitle, context
                            
                        return handler.handleNew 'start', socket, originTitle, context


                resume: (socket) -> 

                    (originTitle, secret, context) -> 

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

                        if previousID = hubContext.name2id[originTitle]

                            return handler.handleExisting 'resume', socket, previousID, originTitle, context 

                        return handler.handleNew 'resume', socket, originTitle, context



                accept: (startOrResume, newSocket, client, originTitle, newContext) ->

                    id = newSocket.id
                    hubContext.clients[id] = client
                    client.connection ||= {}
                    client.connection.state    = 'connected'
                    client.connection.stateAt  = Date.now()

                    #
                    # create hubside clientbound capsule emitters
                    # -------------------------------------------
                    # 
                    # * these do not have an associated middleware pipeline
                    # * it does send with capsule format format (which needs tightenting)
                    # 

                    if config.client? and config.client.capsule?
                        
                        for type of config.client.capsule

                            do (type) ->  

                                client[type] = (title, payload) -> 

                                    header  = [PROTOCOL_VERSION]
                                    control = 
                                        type: type
                                        # uuid: 
                                        protected: { _type: 1 }
                                        hidden:    { _type: 1 }

                                    payload ||= {}
                                    payload._type = type
                                    payload[type] = title
                                    newSocket.emit 'capsule', header, control, payload


                    #
                    # TODO: context as capsule with watched properties
                    # TODO: store context (persistance plugin) to enable
                    #       client attach to different server and resume
                    #       on previous accumulated state
                    # 

                    for key of newContext
                        client.context[key] = newContext[key]

                    #
                    # emit control 'start' or 'resume'
                    # --------------------------------
                    #
                    # * does not wait for result
                    # * TODO: ensure this does not go to the client
                    # 

                    hubNotifier.$$control startOrResume, 
                        _socket_id: id
                    
                    hubContext.name2id[originTitle] = id
                    newSocket.emit 'accept'


                reject: (socket, details) -> 

                    socket.emit 'reject', details
                    socket.disconnect()
                    return


                handleNew: (startOrResume, socket, originTitle, context) ->

                    client = 
                        title:   originTitle
                        context: context
                        hub:     hubName
                    
                    Object.defineProperty client, 'socket', 
                        enumerable: false
                        get: -> 
                            process.stderr.write "notice: capacity to use the client socket directly is unlikely permanent functionality"
                            socket

                    #handler.assign socket
                    handler.accept startOrResume, socket, client, originTitle, context


                handleExisting: (startOrResume, newSocket, previousID, originTitle, newContext) -> 

                    client = hubContext.clients[previousID]

                    if client.connection.state == 'connected'

                        #
                        # first client with this originTitle is still 
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
                    delete hubContext.name2id[originTitle]
                    #handler.assign newSocket
                    handler.accept startOrResume, newSocket, client, originTitle, newContext


    return api = 
        create: Handler.create
