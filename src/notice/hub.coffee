listen     = require './listen'
Notifier   = require './notifier'

module.exports.create = (hubName, opts, callback) -> 

    unless typeof hubName is 'string' 

        throw new Error 'Notifier.listen( hubName, opts ) requires hubName as string'


    responders      = {}
    assignResponder = (context, socket, callback) -> 

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

                context: context
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


        socket.on 'handshake', (secret, context) -> 

            if secret == opts.listen.secret

                #
                # remote notifier authenticated
                #

                assignResponder context, socket, -> socket.emit 'accept'

            else 

                socket.disconnect()


        for event in ['info', 'event']

            do (event) -> 

                #
                # inbound event from the socket are directed into
                # the middleware pipeline
                #

                socket.on event, (context, msg) -> 

                    msg.direction = 'in'
                    msg.origin    = context.origin
                    title         = context.title
                    tenor         = context.tenor
                    

                    #
                    #TEMPORARY1                    
                    # 
                    # storage key for message responder
                    #

                    msg['socket.id'] = socket.id

                    inbound[event][tenor] title, msg



        socket.on 'disconnect', -> 

