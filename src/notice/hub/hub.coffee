{deferred}  = require 'also'
listener    = require './listener'
{handler}   = require './hub_handler'
{notifier}  = require '../notifier'
{manager}   = require '../../management/manager'
{ticker}    = require '../../management/ticker'
{v1}        = require 'node-uuid'

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

    if config.client? then for type in config.client.capsule

        throw reservedCapsule type if type.match(
            /^connect$|^handshake$|^accept$|^reject$|^disconnect$|^resume$|^capsule$|^nak$|^ack$|^error$/
        )

    #
    # * manager is shared on the config object
    # 

    config.running ||= {}
    if config.manager? and not config.running.manager?
        config.running.manager = manager config


    testable = local = 

        Notifier: notifier config
        Handler:  handler  config
        tickers:  ticker config

        hubs:    {}
        clients: {}
        name2id: {} # same client on multiple hubs? later...

        uuids:   {} # taken list for hubs
        
        #
        # TODO: hub has uplink configured from superscope (factory config)
        #

        create: deferred ({reject, resolve, notify}, hubName, opts = {}, callback) ->

            opts.uuid ||= v1()

            try 

                if typeof hubName is 'object'

                    callback = opts
                    opts = hubName
                    hubName = hubName.title

                throw undefinedArg 'hubName' unless typeof hubName is 'string'
                throw alreadyDefined 'hubName', hubName if local.hubs[hubName]?
                throw alreadyDefined 'hubUUID', opts.uuid if local.uuids[opts.uuid]?

                hub = local.Notifier.create hubName, opts.uuid
                hub.cache = opts.cache or {}
                hub.tools = opts.tools or {}
                local.hubs[hubName]    = hub
                local.uuids[opts.uuid] = hub
                local.tickers.register hub, opts

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
                hub.listening.adaptor = 'socket.io'
                resolve hub
                if typeof callback == 'function' then callback null, hub


            handle = local.Handler.create hubName, hub, local, opts
            io.on 'connection', (socket) -> 

                socket.on 'handshake',  handle.handshake   socket
                socket.on 'disconnect', handle.disconnect  socket
                socket.on 'resume',     handle.resume      socket
                socket.on 'capsule',    handle.capsule     socket
                
    #
    # register hubContext with the manager
    # ------------------------------------
    # 
    # * only done once, it registers the hub `Definition`
    # * LATER manager also has access to the Hub.create()
    # 

    if config.running.manager? 
        config.running.manager.register local



    return api = 
        create: local.create

