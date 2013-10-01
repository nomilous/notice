`npm install notice`

### Version 0.0.11

**unstable** - api changes almost certainly will occur (without deprecation warnings)

notice
======

A middleware based communications scaffold.


The Standalone Notifier
-----------------------

Implementes a MessageBus for communications confined to a single process.

#### create a default notifier

```coffee

notice   = require 'notice'
notifier = notice.create 'origin name'

#
# Send an event 
#

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

notifier.use (msg, next) -> 
    
    msg.myContribution = '∑'
    next()

    #
    # why Middleware ?
    # ----------------
    # 
    # * The combination of subscribe-ability and assembly-line
    #   creates a powerful tool.
    # 

#
# Or middleware with a Title
#

notifier.use title: 'Pie Thrower', (msg, next) -> 
    
    throw 'π'

    #
    # why a Title ? 
    # -------------
    # 
    # * The (not yet implemented) bottleneck identifiability.
    # 

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


