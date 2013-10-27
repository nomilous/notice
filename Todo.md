#### todo 0.0.12

* ohdear... capsule.$$all not available in hotswapped middleware... (scope/../scope)
* make fn part of opts in use()
* upsert PUT, POST middleware over api as `text/javascript|coffeescript` hash, including function
* boomerang capsule (emitter callback/resolve only after full remote hub traversal, throw/reject the same, boomerang is the default, emitters not expecting a result from the remote hub should specify on capsule definition, said emitters receive the callback on hub ack)
* boomerang mode - pre / post (configable does the clientside traversal occur after or before the hub traversal)
    * this may be more likely a bus global configable, but it woul be most idea if it was a per capsule type configable


#### todo ___

* transport adaptor TLS   (with client and server certs)
* (maybe) transport adaptor HTTPS (without sockets)
* hub cluster


#### todo ...

```
          notice/• grep -A10 -ri todo src/* 
src/api/authenticator.coffee:                # TODO: error properly?
src/api/authenticator.coffee-                # 
src/api/authenticator.coffee-                # * it re-requests auth on error or no authenticEntity
src/api/authenticator.coffee-                # * otherwise call onward to the requestHandler
src/api/authenticator.coffee-                # 
src/api/authenticator.coffee-
src/api/authenticator.coffee-                return requestHandler request, response if authenticEntity?
src/api/authenticator.coffee-                requestAuth response
src/api/authenticator.coffee-
src/api/authenticator.coffee-        #
src/api/authenticator.coffee-        # * use 'hard'coded username and password in config
--
src/api/middleware.coffee:            # TODO: * pend reload till signal 
src/api/middleware.coffee:            # TODO: * emit $$ready 'pack_id'
src/api/middleware.coffee-            #
src/api/middleware.coffee-
src/api/middleware.coffee-            next = if local.active == 'array1' then 'array2' else 'array1'
src/api/middleware.coffee-
src/api/middleware.coffee-            sort = []
src/api/middleware.coffee-            sort[parseInt slot] = slot for slot of local.slots
src/api/middleware.coffee-
src/api/middleware.coffee-            array = local[next]
src/api/middleware.coffee-            array.length = 0
src/api/middleware.coffee-
--
src/api/ticker.coffee:            # TODO: tick capsule are not sent across the socket
src/api/ticker.coffee-            #
src/api/ticker.coffee-
src/api/ticker.coffee-    api = 
src/api/ticker.coffee-
src/api/ticker.coffee-        register: local.register
--
src/notice/capsule/capsule.coffee:                        # TODO: Consider enabling access to all hubs in the process
src/notice/capsule/capsule.coffee-                        #       to the change watcher callback. (switching / routing)
src/notice/capsule/capsule.coffee-                        #
src/notice/capsule/capsule.coffee-
src/notice/capsule/capsule.coffee-                        opts.watched 
src/notice/capsule/capsule.coffee-                            property: key
src/notice/capsule/capsule.coffee-                            from:     previous
src/notice/capsule/capsule.coffee-                            to:       value
src/notice/capsule/capsule.coffee-                            capsule:  @
src/notice/capsule/capsule.coffee-
src/notice/capsule/capsule.coffee-            @[key] = opts[key]
--
src/notice/client/client.coffee:    # TODO: this bypasses config of the capsule supercope, 
src/notice/client/client.coffee-    #       not doing so becomes necessary later.
src/notice/client/client.coffee-    #
src/notice/client/client.coffee-
src/notice/client/client.coffee-    Capsule = require('../capsule/capsule').capsule()
src/notice/client/client.coffee-
src/notice/client/client.coffee-
src/notice/client/client.coffee-    testable = local = 
src/notice/client/client.coffee-
src/notice/client/client.coffee-        Notifier: notifier.notifier config
src/notice/client/client.coffee-        tickers:    ticker config
--
src/notice/client/client.coffee:                    # TODO: is socket connected?
src/notice/client/client.coffee-                    #       what happens when sending on not 
src/notice/client/client.coffee-                    #
src/notice/client/client.coffee-                    # 
src/notice/client/client.coffee-                    header = [PROTOCOL_VERSION]
src/notice/client/client.coffee-
src/notice/client/client.coffee-                    #
src/notice/client/client.coffee:                    # TODO: much room for optimization here
src/notice/client/client.coffee:                    # TODO: move this into {protocol}.encode
src/notice/client/client.coffee-                    # 
src/notice/client/client.coffee-
src/notice/client/client.coffee-                    control = 
src/notice/client/client.coffee-                        type:      capsule.$$type
src/notice/client/client.coffee-                        uuid:      capsule.$$uuid
src/notice/client/client.coffee-                        protected: capsule.$$protected
src/notice/client/client.coffee-                        hidden:    capsule.$$hidden
src/notice/client/client.coffee-
src/notice/client/client.coffee-                    socket.emit 'capsule', header, control, capsule.$$all
src/notice/client/client.coffee-                    
--
src/notice/client/client.coffee:                    # TODO: transit collection needs limits set, it is conceivable
src/notice/client/client.coffee-                    #       that an ongoing malfunction could guzzle serious memory
src/notice/client/client.coffee:                    # TODO: using a fullblown uuid as key is possibly excessive?
src/notice/client/client.coffee-                    # 
src/notice/client/client.coffee-
src/notice/client/client.coffee-                    #
src/notice/client/client.coffee-                    # * pend the final middleware resolver till either ack or nak
src/notice/client/client.coffee-                    #   from the hub
src/notice/client/client.coffee-                    #
src/notice/client/client.coffee-
src/notice/client/client.coffee-                    transit[capsule.$$uuid] = next: next
src/notice/client/client.coffee-
src/notice/client/client.coffee-                    # 
--
src/notice/client/client.coffee:            # TODO: no ack or nak ever arrives, entries remain in transit 
src/notice/client/client.coffee-            #       collection indefinately 
src/notice/client/client.coffee-            #    
src/notice/client/client.coffee-            #
src/notice/client/client.coffee-
src/notice/client/client.coffee-            socket.on 'ack', (control) -> 
src/notice/client/client.coffee-
src/notice/client/client.coffee-                try 
src/notice/client/client.coffee-                    {uuid} = control
src/notice/client/client.coffee-                    {next} = transit[uuid]
src/notice/client/client.coffee-                    try delete transit[uuid]
--
src/notice/client/client.coffee:                    # TODO: inform resumed onto the local middleware 
src/notice/client/client.coffee-                    #
src/notice/client/client.coffee-
src/notice/client/client.coffee-                    return
src/notice/client/client.coffee-
src/notice/client/client.coffee-                client.connection.state   = 'connecting'
src/notice/client/client.coffee-                client.connection.stateAt = Date.now()
src/notice/client/client.coffee-                socket.emit 'handshake', title, opts.connect.secret || '', opts.context || {}
src/notice/client/client.coffee-
src/notice/client/client.coffee-                #
src/notice/client/client.coffee-                # * server will respond with 'accept' on success, or disconnect()
--
src/notice/client/client.coffee:                    # TODO: inform resumed onto the local middleware 
src/notice/client/client.coffee:                    # TODO: hub context
src/notice/client/client.coffee-                    # 
src/notice/client/client.coffee-
src/notice/client/client.coffee-                    client.connection.state   = 'accepted'
src/notice/client/client.coffee-                    client.connection.stateAt = Date.now()
src/notice/client/client.coffee-                    client.connection.interruptions ||= count: 0
src/notice/client/client.coffee-                    client.connection.interruptions.count++
src/notice/client/client.coffee-                    return 
src/notice/client/client.coffee-
src/notice/client/client.coffee-                #
src/notice/client/client.coffee:                # TODO: hub context
src/notice/client/client.coffee-                # 
src/notice/client/client.coffee-
src/notice/client/client.coffee-                client.connection.state   = 'accepted'
src/notice/client/client.coffee-                client.connection.stateAt = Date.now()
src/notice/client/client.coffee-                resolve client
src/notice/client/client.coffee-                if typeof callback == 'function' then callback null, client
src/notice/client/client.coffee-
src/notice/client/client.coffee-
src/notice/client/client.coffee-            socket.on 'reject', (rejection) -> 
src/notice/client/client.coffee-
--
src/notice/client/client.coffee:                    # TODO: notifier.destroy title (another one in on 'error' below)
src/notice/client/client.coffee-                    #       (it will still be present in the collection there)
src/notice/client/client.coffee-                    #
src/notice/client/client.coffee:                    # TODO: formalize errors 
src/notice/client/client.coffee-                    #       (this following is horrible)
src/notice/client/client.coffee-                    # 
src/notice/client/client.coffee-
src/notice/client/client.coffee-                    delete local.clients[title]
src/notice/client/client.coffee-                    terminal disconnected(title), reject, callback unless already
src/notice/client/client.coffee-                    already = true
src/notice/client/client.coffee-                    return 
src/notice/client/client.coffee-                
src/notice/client/client.coffee-                #
src/notice/client/client.coffee-                # fully established connection has been lost
--
src/notice/client/client.coffee:                # TODO: inform interrupted onto the local middleware 
src/notice/client/client.coffee-                #
src/notice/client/client.coffee-
src/notice/client/client.coffee-
src/notice/client/client.coffee-
src/notice/client/client.coffee-            socket.on 'error', (error) -> 
src/notice/client/client.coffee-                unless client.connection? and client.connection.state == 'pending'
src/notice/client/client.coffee-                    
src/notice/client/client.coffee-                    #
src/notice/client/client.coffee:                    # TODO: handle error after connect|accept
src/notice/client/client.coffee-                    #
src/notice/client/client.coffee-
src/notice/client/client.coffee:                    console.log 'TODO: handle socket error after connect|accept'
src/notice/client/client.coffee-                    console.log error
src/notice/client/client.coffee-                    return
src/notice/client/client.coffee-
src/notice/client/client.coffee-
src/notice/client/client.coffee-                delete local.clients[title]
src/notice/client/client.coffee-                setTimeout (-> 
src/notice/client/client.coffee-
src/notice/client/client.coffee-                    # 
src/notice/client/client.coffee-                    # `opts.connect.errorWait`
src/notice/client/client.coffee-                    # 
--
src/notice/client/connector.coffee:    # TODO: adaptor plugin ability
src/notice/client/connector.coffee-    #
src/notice/client/connector.coffee-    
src/notice/client/connector.coffee-    # opts.adaptor ||= 'socket.io'
src/notice/client/connector.coffee-    # opts.url     ||= 'https://localhost'
src/notice/client/connector.coffee-
src/notice/client/connector.coffee-    if opts.rejectUnauthorized?
src/notice/client/connector.coffee-        require('https').globalAgent.options.rejectUnauthorized = opts.rejectUnauthorized
src/notice/client/connector.coffee-
src/notice/client/connector.coffee-    ioclient.connect opts.url
--
src/notice/errors.coffee:# TODO: errno for implementation exit codes
src/notice/errors.coffee:# TODO: more context into error outputs, eg, which .thing, and what was .propery at the time
src/notice/errors.coffee-# 
src/notice/errors.coffee-
src/notice/errors.coffee-module.exports.terminal = (error, reject, callback) -> 
src/notice/errors.coffee-    
src/notice/errors.coffee-    reject error if typeof reject is 'function'
src/notice/errors.coffee-    if typeof callback == 'function' then callback error
src/notice/errors.coffee-
src/notice/errors.coffee-
src/notice/errors.coffee-module.exports.reservedCapsule = (type) -> 
src/notice/errors.coffee-    
--
src/notice/hub/hub.coffee:        # TODO: hub has uplink configured from superscope (factory config)
src/notice/hub/hub.coffee-        #
src/notice/hub/hub.coffee-
src/notice/hub/hub.coffee-        create: deferred ({reject, resolve, notify}, hubName, opts = {}, callback) ->
src/notice/hub/hub.coffee-
src/notice/hub/hub.coffee-            opts.uuid ||= v1()
src/notice/hub/hub.coffee-
src/notice/hub/hub.coffee-            try 
src/notice/hub/hub.coffee-
src/notice/hub/hub.coffee-                if typeof hubName is 'object'
src/notice/hub/hub.coffee-
--
src/notice/hub/hub_handler.coffee:    # TODO: this bypasses config of the capsule supercope, 
src/notice/hub/hub_handler.coffee-    #       not doing so becomes necessary later.
src/notice/hub/hub_handler.coffee-    #
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-    Capsule = require('../capsule/capsule').capsule()
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-    Testable = Handler =
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-        create: (hubName, hubNotifier, hubContext, opts) -> 
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-            hubNotifier.use 
--
src/notice/hub/hub_handler.coffee:                    # TODO: client requests disconnect, emit 'stop'
src/notice/hub/hub_handler.coffee-                    # * client disconnects without intending, emit 'suspend'
src/notice/hub/hub_handler.coffee:                    # TODO: suspended / stopped client is reaped, emit: 'terminate'
src/notice/hub/hub_handler.coffee-                    #
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-                    ->
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-                        id = socket.id
src/notice/hub/hub_handler.coffee-                        try client = hubContext.clients[id]
src/notice/hub/hub_handler.coffee-                        return unless client?
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-                        client.connection ||= {}
src/notice/hub/hub_handler.coffee-                        client.connection.state    = 'disconnected'
--
src/notice/hub/hub_handler.coffee:                        # * TODO: ensure this does not go to the client
src/notice/hub/hub_handler.coffee-                        # 
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-                        hubNotifier.$$control 'suspend', 
src/notice/hub/hub_handler.coffee-                            _socket_id: id
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-                capsule: (socket) -> 
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-                    ### grep PROTOCOL1 decode ###
src/notice/hub/hub_handler.coffee-
--
src/notice/hub/hub_handler.coffee:                        # TODO: raw.control.type might may be extraneous
src/notice/hub/hub_handler.coffee-                        #
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-                        try tected  = control.protected
src/notice/hub/hub_handler.coffee-                        try hidden  = control.hidden
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-                        capsule = new Capsule uuid: uuid
src/notice/hub/hub_handler.coffee-                        for property of payload
src/notice/hub/hub_handler.coffee-                            assign = {}
src/notice/hub/hub_handler.coffee-                            assign[property] = payload[property]
src/notice/hub/hub_handler.coffee-                            assign.hidden    = true if hidden[property]
--
src/notice/hub/hub_handler.coffee:                        # TODO: consider letting the middleware if the client should
src/notice/hub/hub_handler.coffee-                        #       be accepted
src/notice/hub/hub_handler.coffee-                        #
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-                        if previousID = hubContext.name2id[originTitle]
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-                            return handler.handleExisting 'start', socket, previousID, originTitle, context
src/notice/hub/hub_handler.coffee-                            
src/notice/hub/hub_handler.coffee-                        return handler.handleNew 'start', socket, originTitle, context
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-
--
src/notice/hub/hub_handler.coffee:                    # TODO: context as capsule with watched properties
src/notice/hub/hub_handler.coffee:                    # TODO: store context (persistance plugin) to enable
src/notice/hub/hub_handler.coffee-                    #       client attach to different server and resume
src/notice/hub/hub_handler.coffee-                    #       on previous accumulated state
src/notice/hub/hub_handler.coffee-                    # 
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-                    for key of newContext
src/notice/hub/hub_handler.coffee-                        client.context[key] = newContext[key]
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-                    #
src/notice/hub/hub_handler.coffee-                    # emit control 'start' or 'resume'
src/notice/hub/hub_handler.coffee-                    # --------------------------------
--
src/notice/hub/hub_handler.coffee:                    # * TODO: ensure this does not go to the client
src/notice/hub/hub_handler.coffee-                    # 
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-                    hubNotifier.$$control startOrResume, 
src/notice/hub/hub_handler.coffee-                        _socket_id: id
src/notice/hub/hub_handler.coffee-                    
src/notice/hub/hub_handler.coffee-                    hubContext.name2id[originTitle] = id
src/notice/hub/hub_handler.coffee-                    newSocket.emit 'accept'
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-                reject: (socket, details) -> 
--
src/notice/hub/hub_handler.coffee:                        # TODO: make this configurable
src/notice/hub/hub_handler.coffee-                        #       - keep new and kill old
src/notice/hub/hub_handler.coffee-                        #       - confirm old before rejecting new
src/notice/hub/hub_handler.coffee-                        #             -- by probe
src/notice/hub/hub_handler.coffee-                        #             -- by last activity age
src/notice/hub/hub_handler.coffee-                        #             BAD if rejecting new when old is broken
src/notice/hub/hub_handler.coffee-                        #       - ??? keep both
src/notice/hub/hub_handler.coffee-                        # 
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-                        newSocket.emit 'reject',
src/notice/hub/hub_handler.coffee-
--
src/notice/hub/hub_handler.coffee:                    # * TODO: make performing a compariton of old and new 
src/notice/hub/hub_handler.coffee-                    #         context a posibility, probably down the pipeline
src/notice/hub/hub_handler.coffee-                    # 
src/notice/hub/hub_handler.coffee-                    # * FOR NOW the old context is kept and new is ignored
src/notice/hub/hub_handler.coffee-                    #   =======
src/notice/hub/hub_handler.coffee-                    # 
src/notice/hub/hub_handler.coffee-
src/notice/hub/hub_handler.coffee-                    delete hubContext.clients[previousID]
src/notice/hub/hub_handler.coffee-                    delete hubContext.name2id[originTitle]
src/notice/hub/hub_handler.coffee-                    #handler.assign newSocket
src/notice/hub/hub_handler.coffee-                    handler.accept startOrResume, newSocket, client, originTitle, newContext
--
src/notice/notifier.coffee:                                                # TODO: how many traversals per second does it
src/notice/notifier.coffee-                                                #       take to wedge the scheduler...??
src/notice/notifier.coffee-                                                # 
src/notice/notifier.coffee-                                                #       and what does a wedged scheduler look like
src/notice/notifier.coffee-                                                #       from the outside (here)
src/notice/notifier.coffee-                                                # 
src/notice/notifier.coffee-                                                #       do the nextTicks just not happen? (silently?)
src/notice/notifier.coffee-                                                # 
src/notice/notifier.coffee-                                                # 1
src/notice/notifier.coffee-                            next = -> process.nextTick -> resolve capsule
src/notice/notifier.coffee-                                                        # 2

          notice/• 


```


### ideas...

```
src/api/middleware.coffee:                    # ##ideas
src/api/middleware.coffee-                    # 
src/api/middleware.coffee-                    # * the middleware, contained in a capsule
src/api/middleware.coffee-                    #      * provides a change watcher
src/api/middleware.coffee-                    #      * uuid
src/api/middleware.coffee-                    # * switching middleware, instruction via the pipeline in addition to the api
src/api/middleware.coffee-                    # * middleware packs (a contiguous, identifiable set)
src/api/middleware.coffee-                    #      * hub runs a pack
src/api/middleware.coffee-                    #      * can switch betweeen packs
src/api/middleware.coffee:                    #           * nice for preloading an ugrade pending ideal switch moment
src/api/middleware.coffee-                    #           * switch back if it blows up
src/api/middleware.coffee-                    #  
src/api/middleware.coffee-                    #      == suggests sluce ==
src/api/middleware.coffee-                    #               
src/api/middleware.coffee-                    #              * a 'first' middleware that queues when activated
src/api/middleware.coffee-                    #              * and can open the floodgate carefully
src/api/middleware.coffee-                    #              * to only release a trickle onto the newly upgraded bus
src/api/middleware.coffee-                    #              * to determine if a rollback (and return to the DrawingBoard) is necessary
src/api/middleware.coffee-                    # 
src/api/middleware.coffee-
```


