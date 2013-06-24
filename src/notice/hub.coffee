listen = require './listen'

module.exports.create = (hubName, opts, callback) -> 
    
    unless typeof hubName is 'string' 

        throw new Error 'Notifier.listen( hubName, opts ) requires hubName as string'

    opts               ||= {}
    opts.listen        ||= {}
    opts.listen.secret ||= ''
    opts.hub  = 
        socket: {}
        context: {}

    io = listen 

        address: opts.listen.address
        port:    opts.listen.port
        cert:    opts.listen.cert
        key:     opts.listen.key

        (error, address) -> 

            #
            # reference to the listening address on the hub
            # 

            opts.hub.listening = address
            callback error, null if typeof callback == 'function'




    io.on 'connection', (socket) -> 


        socket.on 'handshake', (secret, context) -> 

            if secret == opts.listen.secret

                opts.hub.socket[  socket.id ] = socket
                opts.hub.context[ socket.id ] = context

                socket.emit 'accept'

            else 

                socket.disconnect()




        socket.on 'disconnect', -> 

    
    return opts
