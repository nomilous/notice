{bus1, bus2} = require './message_bus'

interval   = undefined
count      = 1
sendUpdate = -> 
    
    #
    # bus2 defines `update` as a message type
    #

    message = progress: "#{count++} of 2"

    #
    # emit the message as update onto bus2 with a 
    # node style callback to receive a possible 
    # error or the message after it being processed
    # by all registered middleware on bus2
    #
    
    bus2.update message, (err, res) -> 

        console.log ok: res.ok

    #
    # the emit function also returns a promise
    # for those of us that like then
    #
    # bus2.update( message ).then(
    #     (res) -> console.log ok: res.ok
    #     (err) -> 
    # )
    #


bus1.use (msg, next) -> 

    #
    # register middleware on bus1
    #

    console.log 'component_TWO received:', msg
    if msg.run?  then interval = setInterval sendUpdate, 1000
    if msg.stop? then clearInterval interval
    next()
