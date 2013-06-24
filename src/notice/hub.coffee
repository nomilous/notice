listen   = require './listen'
Notifier = require './notifier'

module.exports.create = (hubName, opts, callback) -> 
    
    unless typeof hubName is 'string' 

        throw new Error 'Notifier.listen( hubName, opts ) requires hubName as string'

    opts               ||= {}
    opts.listen        ||= {}
    opts.listen.secret ||= ''
    opts.hub = {} 
    # opts.hub =
        #
        # probably dont need these... (yet)
        #
        # socket: {}
        # context: {}

    #
    # hubside message pipeline
    #

    notice = Notifier.create hubName


    io = listen 

        address: opts.listen.address
        port:    opts.listen.port
        cert:    opts.listen.cert
        key:     opts.listen.key

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

                callback error, notice




    io.on 'connection', (socket) -> 


        socket.on 'handshake', (secret, context) -> 

            if secret == opts.listen.secret

                # opts.hub.socket[  socket.id ] = socket
                # opts.hub.context[ socket.id ] = context

                socket.emit 'accept'

            else 

                socket.disconnect()


        for event in ['info', 'event']

            do (event) -> 

                #
                # inbound event from the socket are directed into
                # the middleware pipeline
                #

                socket.on event, (payload) -> 

                    title  = payload.context.title
                    tenor  = payload.context.tenor

                    #
                    # TODO: origin? hmmmm
                    #

                    #origin = payload.context.origin

                    notice[event][tenor] title, payload



        socket.on 'disconnect', -> 

    
    return opts
