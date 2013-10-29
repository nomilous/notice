{deferred}  = require 'also'
listener    = require './listener'
{handler}   = require './hub_handler'
{notifier}  = require '../notifier'
{manager}   = require '../../api/manager'
{ticker}    = require '../../api/ticker'
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

    #
    # * manager is shared on the config object
    # 

    config.running ||= {}
    if config.api? and not config.running.api?
        config.running.api = manager config


    testable = local = 

        Notifier: notifier config
        Handler:  handler  config
        tickers:  ticker config

        hubs:    {}
        names:   {}

        clients: {}
        name2id: {} # client name to socket.io id mapping
                    # TODO: key clients on uuid not title! 
                    # used in persisting context across client restarts

        create: deferred ({reject, resolve, notify}, opts = {}, callback) ->

            try 

                hubName = opts.title
                uuid    = opts.uuid || v1()

                throw undefinedArg   'hubName'  unless typeof hubName is 'string'
                throw alreadyDefined 'hubName', hubName if local.names[hubName]?
                throw alreadyDefined 'hubUUID', uuid if local.hubs[uuid]?

                
                hub  = local.Notifier.create hubName, uuid
                hub.cache = opts.cache or {}
                hub.tools = opts.tools or {}
                local.hubs[uuid]     = hub
                local.names[hubName] = 1
                local.tickers.register hub, opts


                seq = 0
                setInterval (-> hub.$health seq: seq++ ), 60000


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

    if config.running.api? 
        config.running.api.register local



    return api = 
        create: local.create

