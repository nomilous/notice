`npm install notice`

### Version 0.0.11

**unstable** - api changes almost certainly will occur (without deprecation warnings)

notice
======

A middleware based communications scaffold.


The Standalone Notifier
-----------------------

Implementes a MessageBus for communications confined to a single process.

### create an event notifier (the default)

```coffee

notice   = require 'notice'
notifier = notice.create 'origin name'

```
#### send an event
```coffee

notifier.event 'event name', { optional: 'payload' }

#
# Send an event and assign a callback to receive the result.
#

notifier.event 'event name', {}, (err, msg) -> 
    
    # 
    # * Middleware traversal is terminated upon the first
    #   throw or uncaught exception inside the pipeline 
    #   and the `err` is passed here.
    # 
    # * Otherwise `msg` is populated with the message as 
    #   modified by middlewares registered on the notifier.
    # 

```
#### register some middleware
```coffee

notifier.use (done, msg) -> 
    
    msg.myContribution = '∑'
    done()

    #
    # why Middleware ?
    # ----------------
    # 
    # * The combination of subscribe-ability and assembly-line
    #   creates a powerful tool.
    # 

#
# Register middleware with Title
#

notifier.use title: 'Pie Thrower', (done, msg) -> 
    
    throw 'π'

    #
    # why a Title ? 
    # -------------
    # 
    # * The (not yet implemented) bottleneck identifiability.
    # 

```
#### use the promise instead
```coffee

notifier.event 'event name',

    sending:   'this message'
    with:      'a promise waiting'
    insteadOf: 'a node style callback waiting'
    forThe:    'finalMessage'

.then(

    (finalMessage) -> 
    (error) -> console.log error == 'π'

)

```


### create a notifier that does more than just 'event()'

```coffee
os         = require 'os'
notice     = require 'notice'

{hostname, uptime, loadavg, totalmem, freemem} = os

module.exports.MessageBus = notice
    
    messages:

        alert: 
            beforeCreate: (done, msg) -> 
                msg.sourceInfo = 
                    hostname: hostname()
                    uptime: uptime()
                    loadavg: loadavg()
                    totalmem: totalmem()
                    freemem: freemem()
                done()
            afterCreate:  (done, msg) -> 

                #
                # * This fires before the message is pushed onto the
                #   middleware pipeline.
                # 
                # * It creates an opportunity to pre-store the message
                #   and therefore have the persistence id/ref/uuid
                #   already assigned before emitting into runtime.
                # 

        classify: {}
        resolve:  {}
        escalate: {}
        debrief:  {}
        reclassify: {}

```
#### use it
```coffee

{MessageBus} = require 'the_previous_block'

notifier = MessageBus.create 'origin_app_name'
notifier.alert "darn, i thought this wouldn't happen", 
    
    says: 'the developer'
    heresWhatIKnow: """ 

        Recorded at the time of writing the code. 

    """

```


The Distributable Notifier
==========================


The Hub
-------

`Notice.listen(hubName, opts, callback)`

```coffee

Notice.listen 'Hub Name', 

    #
    # Configure with opts.listen
    # -------------------------- 
    # 
    #  * Using socket.io
    #  * PENDING: adaptor abstraction to enable transport plugins
    #

    listen:

        secret:   '◊'
        port:     10101
        address:  '0.0.0.0'
        cert:   __dirname + '/cert/develop-cert.pem'
        key:    __dirname + '/cert/develop-key.pem'


    #
    # Callback receives listening hub
    # -------------------------------
    # 
    # * hub is the interface to remote notifiers
    # * ... precise api design still in progress
    #

    (error, hub) -> 

        throw error if error?

        #
        # assign middleware to handle arriving messages
        #

        hub.use (msg, next) -> 

            console.log 'RECEIVE:', msg.context.origin, msg

            #
            # reply across the response pipeline
            #

            msg.context.responder.info 'reply title', {pay: 'load'}
            next()


```



The Client
----------

`Notice.connect(clientName, opts, callback)`

```coffee

Notice.connect 'Client Name',
        
    connect:

        secret:      '◊'
        port:       10101
        transport: 'https'
    
    (error, notice) -> 

        throw error if error?

        #
        # assign middleware to process messages
        # -------------------------------------
        # 
        # * client has only one middleware pipeline
        # * messages define context.direction (in|out)
        #   to distinguish between inbound an outbound 
        #   messages
        #

        notice.use (msg, next) ->

            switch msg.context.direction

                when 'out' then console.log 'SEND:   ', msg.context.title, msg

                when 'in'  then console.log 'RECEIVE:', msg.context.origin, msg


            next()


        #
        # send an event message
        #

        notice.event 'connect', hello: "i'm online"


```


The Future
==========

### possible features / general intensions

* named middleware (can be added and removed from the pipeline)
* flood protection
* time in pipeline / backlog (introspection)
* error / exception detecion in pipeline (carried out on the promise)
* as message receiver
* tasks and escalations (with persistor plugin / state machine)
* hubside pipeline promise
* acknowledgability / take (state)
* updatability
* resolvability            (state)
* expire / escalate        (state)
* mobile APIs (systems are more commonly composed **of people** than software)
* requirejs / amdefine to enable browserside notifier client


