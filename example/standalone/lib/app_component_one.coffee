{bus1} = require './message_bus'

bus1.use title: 'component one', (done, msg) -> 

    console.log 'component_ONE received:', msg
    done()
