{deferred} = require 'also'
Listener   = require './listener'
notifier   = require './notifier'

testable            = undefined
module.exports._hub = -> testable
module.exports.hub  = (config = {}) ->

    testable = local = 

        Notifier: notifier.notifier config

        hubs: {}

        create: deferred ({reject, resolve, notify}, hubName, opts = {}, callback) ->

            unless typeof hubName is 'string'
                error = new Error 'Hub.create( hubName, opts ) requires hubName as string'
                reject error
                if typeof callback == 'function' then callback error
                return

            if local.hubs[hubName]?
                error = new Error "Hub.create( '#{hubName}', opts ) is already defined"
                reject error
                if typeof callback == 'function' then callback error
                return

            #
            # create the hubside middleware pipeline (hub) and start listener
            #

            local.hubs[hubName] = hub = local.Notifier.create hubName
            io = Listener.listen opts.listen, (error, address) -> 

                if error? 

                    reject error
                    if typeof callback == 'function' then callback error
                    return


                #
                # transport is up and listening for remote notifiers,
                # 
                # * create externally accessable reference to the 
                #   listening address (may have defaulted, port
                #   would then be unknown to the caller)
                # 
                # * callback with the hubside pipeline / notifier
                #   to provide caller with access to the middleware
                #   registrar
                # 
                
                hub.listening = address
                resolve hub
                if typeof callback == 'function' then callback null, hub





    return api = 
        create: local.create
















return
listen     = require './listen'
Notifier   = require './notifier'

module.exports.create = (hubName, opts, callback) -> 

    unless typeof hubName is 'string' 

        throw new Error 'Notifier.listen( hubName, opts ) requires hubName as string'


    responders      = {}
    assignResponder = (origin, socket, callback) -> 

        #
        # creates response pipeline back to the remote notifier
        #

        unless responder = responders[socket.id]

            responder = Notifier.create hubName

            responder.first = (msg, next) -> 

                msg.direction = 'out'
                next()

            responder.last = (msg, next) -> 

                type = msg.context.type

                #
                # TODO: strip context (it was/shouldBe sent on handshake)
                # 
                #       - some context should remain (title, type)
                #       - no point in sending the origin on each message
                #       - allows for much more context at no extra cost
                #       - keep in pending persistance layer in mind here
                #

                socket.emit type, msg.context, msg
                next()

            responders[socket.id] = 

                notice: responder

                #
                # TODO: per remote client context 
                # 
                #       - stored locally (at hub)
                #       - created on handshake
                #       - not yet accessable 
                #

                origin: origin
                connected: true

        callback()


    opts               ||= {}
    opts.listen        ||= {}
    opts.listen.secret ||= ''
    opts.hub = {} 


    #
    # hubside message pipeline (INBOUND)
    #

    inbound = Notifier.create hubName

    inbound.use (msg, next) -> 

        #
        #TEMPORARY1
        # 
        # first middleware makes responder accessable 
        # as property of the message
        #

        responder = responders[msg['socket.id']]

        msg.setResponder = responder.notice
        Object.defineProperty msg, 'originContext', 
            enumareable: false
            get: -> responder.origin
                    

        delete msg['socket.id']
        next()


    io = listen 

        loglevel: opts.listen.loglevel
        address:  opts.listen.address
        port:     opts.listen.port
        cert:     opts.listen.cert
        key:      opts.listen.key

        (error, address) -> 

            #
            # socket is up and listening for remote notifiers,
            # 
            # * create externally accessable reference to the 
            #   listening address (may have defaulted, port
            #   would then be unknown to the caller)
            # 
            # * callback with the hubside pipeline / notifier
            #   to provide caller with access to the middleware
            #   registrar
            # 

            opts.listening = address
            
            if typeof callback == 'function'

                callback error, inbound




    io.on 'connection', (socket) -> 


        socket.on 'handshake', (secret, origin) -> 

            if secret == opts.listen.secret

                #
                # remote notifier authenticated
                #

                assignResponder origin, socket, -> socket.emit 'accept'

            else 

                socket.disconnect()


        for event in ['info', 'event']

            do (event) -> 

                #
                # inbound event from the socket are directed into
                # the middleware pipeline
                #

                socket.on event, (context, msg) -> 

                    #
                    # TODO: reconstitute context
                    # 

                    msg.direction     = 'in'
                    msg.origin        = context.origin
                    title             = context.title
                    tenor             = context.tenor

                    #
                    #TEMPORARY1                    
                    # 
                    # storage key for message responder
                    #

                    msg['socket.id'] = socket.id

                    inbound[event][tenor] title, msg



        socket.on 'disconnect', -> 

            #
            # notify responder it is no longer connected 
            # to the remote client
            #

            if responder = responders[socket.id]

                responder.notice.event 'disconnect'
                responder.connected = false


