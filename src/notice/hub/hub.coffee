{deferred} = require 'also'
listener   = require './listener'
{handler}   = require './hub_handler'
{notifier}  = require '../notifier'
{
    terminal
    reservedCapsule
    undefinedArg
    alreadyDefined
} = require '../errors'


testable            = undefined
module.exports._hub = -> testable
module.exports.hub  = (config = {}) ->

    for type of config.capsule

        throw reservedCapsule type if type.match(
             /^connect$|^handshake$|^accept$|^reject$|^disconnect$|^resume$|^capsule$|^nak$|^ack$|^error$/
        )


    testable = local = 

        Notifier: notifier config
        Handler:  handler  config

        hubs:    {}
        clients: {}
        name2id: {} # same client on multiple hubs? later...
        
        #
        # TODO: hub has uplink configured from superscope (factory config)
        #

        connections: -> 

            # console.log '---------'
            # for id of local.clients
            #     client = local.clients[id]
            #     console.log client.title, client.context, client.connected
            # console.log '---------'

        create: deferred ({reject, resolve, notify}, hubName, opts = {}, callback) ->

            try 

                if typeof hubName is 'object'

                    callback = opts
                    opts = hubName
                    hubName = hubName.title

                throw undefinedArg 'hubName' unless typeof hubName is 'string'
                throw alreadyDefined 'hubName', hubName if local.hubs[hubName]?

                hub = local.Notifier.create hubName
                local.hubs[hubName] = hub

            catch error

                return terminal error, reject, callback



            io = listener.listen opts.listen, (error, address) -> 

                if error? 

                    reject error
                    if typeof callback == 'function' then callback error
                    return

                #
                # transport is up and listening for remote notifiers
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


            handle = local.Handler.create hubName, hub, local, opts
            io.on 'connection', (socket) -> 

                socket.on 'handshake',  handle.handshake   socket
                socket.on 'disconnect', handle.disconnect  socket
                socket.on 'resume',     handle.resume      socket
                socket.on 'capsule',    handle.capsule     socket
                


    return api = 
        create: local.create

