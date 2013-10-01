{bus1, bus2} = require './message_bus'

interval   = undefined
count      = 0
sendUpdate = -> 
    
    #
    # bus2 defines `update` as a message type
    #

    bus2.update count: count++

bus1.use (msg, next) -> 

    console.log 'component_TWO received:', msg
    if msg.run?  then interval = setInterval sendUpdate, 1000
    if msg.stop? then clearInterval interval
    next()
