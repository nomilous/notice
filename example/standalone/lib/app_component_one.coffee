{bus1} = require './message_bus'

bus1.use (msg, next) -> 

    console.log 'component_ONE received:', msg
    next()
