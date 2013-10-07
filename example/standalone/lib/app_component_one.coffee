{bus1} = require './message_bus'

bus1.use title: 'component one', (next, capsule) -> 

    console.log 'component_ONE received:', capsule
    next()
