{bus1, bus2} = require './message_bus'

interval   = undefined
count      = 1
sendUpdate = -> 
    
    #
    # bus2 defines `update` as a message type
    #

    message = 
        progress: "#{count++} of 2"
    bus2.update message, (err, res) -> 

        #
        # `res` is the same sent message AFTER 
        # being processed by all the middleware 
        # registered on bus2
        #

        console.log ok: res.ok


bus1.use (msg, next) -> 

    #
    # register middleware on bus1
    #

    console.log 'component_TWO received:', msg
    if msg.run?  then interval = setInterval sendUpdate, 1000
    if msg.stop? then clearInterval interval
    next()
