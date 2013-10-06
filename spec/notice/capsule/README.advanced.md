
### change emitter proxy

```coffee

{EventEmitter} = require 'events'
{bus} = require './an/already/configured/and/instanciated/standalone/notifier'

#
# NOTE! This is only possible with the standalone notifier because
#       it has a synchronous initializer. Distributed notifier hub
#       or client instances cannot be ""easily"" module.exported 
#       because they are initialized into a callback / promise. 
#       

module.exports.stateChangeEmitter = emitter = new EventEmitter

#
# This module will need to be 'required' early in the app 
# init sequence to ensure this middleware is registered
# at the front of the pipeline.
#

bus.use 
    
    title: 'state emitter'
    description: 'proxies state changes to event emitter'
    (done, capsule) -> 

        capsule.set

            state: 'pending'
            watch: (change) -> emitter.emit 'state_change', change

        done()

#
# there may be minor syntax errors (or other things) here
# have not run this code
#

```
```coffee

{stateChangeEmitter} = require 'the_previous_block'
stateChangeEmitter.on 'state_change', (change) -> 
    
    console.log change

```
