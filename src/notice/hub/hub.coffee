{deferred} = require 'also'
listener   = require './listener'
{handler}   = require './hub_handler'
{notifier}  = require '../notifier'


testable            = undefined
module.exports._hub = -> testable
module.exports.hub  = (config = {}) ->

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

            try 
                local.hubs[hubName] = hub = local.Notifier.create hubName
            catch error
                reject error
                if typeof callback == 'function' then callback error
                return

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
                


    return api = 
        create: local.create

