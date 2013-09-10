`npm install notice`

### Version 0.0.9

**unstable** - api changes may occur (without deprecation warnings)

[objective](https://github.com/nomilous/notice/blob/master/objective)

notice
======

A middleware based communications scaffold.


The Standalone Notifier
-----------------------

`notice = Notice.create(originName, defaultMiddleware)`

### Overview

```coffee

#
# Create a notifier with default middleware
# -----------------------------------------
# 

notice = Notice.create 'Origin Name', (msg, next) -> 
    
    console.log msg.content
    next()


#
# Emit messages into the middleware pipeline
# ------------------------------------------
# 
#  * Supports messages of type 'info' and 'event'
#  * PENDING: additional types as use cases arrise
#

notice.info 'title', 'description'
notice.event 'title', { description: 'description', more: ['th','ings'] }

#
# Emit a message and do nothing until all middleware processed it
# ---------------------------------------------------------------
# 
# * As a message bus
# 
# * As an assembly line.
#
# * Averts the often perplexing problem of referenced data changing after 
#   it was emitted (via event.EventEmitter) but while the subscriber(s)
#   are still using it. 
# 

notice.event( 'event name', { complex: 'Object' } ).then (msg) -> 
    
    #
    # All subscribed middlewares have processed the message
    # -----------------------------------------------------
    # 
    # * Some may have modified it (assembly line)
    # * The final resulting message `msg` was passed into this function
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

            msg.reply.info 'title', {pay: 'load'}
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


