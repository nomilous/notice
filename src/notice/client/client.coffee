PROTOCOL_VERSION = 1

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

    for type of config.capsule

        throw reservedCapsule type if type.match(
            /^connect$|^handshake$|^accept$|^reject$|^disconnect$|^resume$|^capsule$|^nak$|^ack$|^error$/
        )

    #
    # TODO: this bypasses config of the capsule supercope, 
    #       not doing so becomes necessary later.
    #

    Capsule = require('../capsule/capsule').capsule()


    testable = local = 

        Notifier: notifier.notifier config
        clients:  {}

        create: deferred ({reject, resolve, notify}, title, opts = {}, callback) -> 
            
            try 

                if typeof title is 'object'

                    callback = opts
                    opts     = title
                    title    = opts.title

                throw undefinedArg 'title' unless typeof title is 'string'
                throw alreadyDefined 'title', title if local.clients[title]?
                throw undefinedArg 'opts.connect.url' unless opts.connect? and typeof opts.connect.url is 'string'
                
                client = local.Notifier.create title, opts.uuid
                local.clients[title] = client

            catch error

                return terminal error, reject, callback


            opts.context ||= {}
            opts.context.hostname = hostname()
            opts.context.pid      = process.pid


            socket = Connector.connect opts.connect

            client.connection       ||= {}
            client.connection.state   = 'pending'
            client.connection.stateAt = Date.now()
            client.cache = opts.cache or {}
            client.tools = opts.tools or {}
            already = false 

            #
            # last middleware on the local bus transfers capsule onto socket 
            # --------------------------------------------------------------
            # 
            # * This only occurrs if the capsule reaches the end of the local 
            #   middleware pipeline.
            #
            # * The final middleware resolver for each capsule sent to the
            #   hub is placed into this transit collection pending certainty
            #   of handover to the hub. (ack)
            # 

            transit = {}

            client.use

                title: 'outbound socket interface'
                last:  true
                (next, capsule) -> 

                    ### grep PROTOCOL1 encode ###

                    #
                    # TODO: is socket connected?
                    #       what happens when sending on not 
                    #
                    # 
                    header = [PROTOCOL_VERSION]

                    #
                    # TODO: much room for optimization here
                    # TODO: move this into {protocol}.encode
                    # 

                    control = 
                        type:      capsule.$$type
                        uuid:      capsule.$$uuid
                        protected: capsule.$$protected
                        hidden:    capsule.$$hidden

                    socket.emit 'capsule', header, control, capsule.$$all
                    
                    #
                    # TODO: transit collection needs limits set, it is conceivable
                    #       that an ongoing malfunction could guzzle serious memory
                    # TODO: using a fullblown uuid as key is possibly excessive?
                    # 

                    #
                    # * pend the final middleware resolver till either ack or nak
                    #   from the hub
                    #

                    transit[capsule.$$uuid] = next: next

                    # 
                    # * Send notification of the transmission to the promise notifier
                    #   waiting at the capsule origin.
                    #   
                    #   Unfortunately a capsule origin with a node style callback
                    #   waiting has no concrete facility to receive this information
                    #   and will remain in the dark until the hub ack / nak.
                    # 

                    process.nextTick -> next.notify
                        $$type:    'control'
                        $$control: 'transmitted'
                        capsule:   capsule


            socket.on 'capsule', (header, control, payload) -> 

                #
                # inbound capsule onto the client side middleware
                #

                [version] = header
                uuid      = control.uuid

                unless version == PROTOCOL_VERSION
                    throw new Error "notice: #{reason} - hub:#{version} thisclient:#{PROTOCOL_VERSION}"

                try tected  = control.protected
                try hidden  = control.hidden

                capsule = new Capsule uuid: uuid
                for property of payload
                    assign = {}
                    assign[property] = payload[property]
                    assign.hidden    = true if hidden[property]
                    assign.protected = true if tected[property]
                    capsule.$$set assign

                client.$$raw capsule

            #
            # TODO: no ack or nak ever arrives, entries remain in transit 
            #       collection indefinately 
            #    
            #

            socket.on 'ack', (control) -> 

                try 
                    {uuid} = control
                    {next} = transit[uuid]
                    try delete transit[uuid]

                catch error
                    process.stderr.write 'notice: invalid or unexpected ACK ' + uuid + '\n'
                    return

                #
                # * ack calls the next() that was pended in the final middleware
                #   at the time of sending the capsule to the hub.
                #

                next()


            socket.on 'nak', (control) -> 

                try 
                    {uuid, reason} = control
                    {next} = transit[uuid]
                    try delete transit[uuid]

                catch error
                    process.stderr.write 'notice: invalid or unexpected NAK ' + uuid + '\n'
                    return

                switch reason

                    when 'protocol mismatch' 

                        try support = control.support.join ','
                        next.reject new Error "notice: #{reason} - hub:#{support} thisclient:#{PROTOCOL_VERSION}"



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
                    socket.emit 'resume', title, opts.connect.secret || '', opts.context || {}

                    #
                    # * server will respond with 'accept' on success, or disconnect()
                    #

                    #
                    # TODO: inform resumed onto the local middleware 
                    #

                    return

                client.connection.state   = 'connecting'
                client.connection.stateAt = Date.now()
                socket.emit 'handshake', title, opts.connect.secret || '', opts.context || {}

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

                terminal connectRejected(title, rejection), reject, callback
                already = true

            socket.on 'disconnect', -> 
                unless client.connection.state == 'accepted'

                    #
                    # the connection was never fully established
                    # ------------------------------------------
                    #
                    # TODO: notifier.destroy title (another one in on 'error' below)
                    #       (it will still be present in the collection there)
                    #
                    # TODO: formalize errors 
                    #       (this following is horrible)
                    # 

                    delete local.clients[title]
                    terminal disconnected(title), reject, callback unless already
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


                delete local.clients[title]
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
                # error = new Error "Client.create( '#{title}', opts ) failed connect"
                # reject error
                # if typeof callback == 'function' then callback error



            


    return api = 
        create: local.create

