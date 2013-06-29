### Version 0.0.7 - (unstable)

`npm install notice`


notice
======

A messaging middleware pipeline.


Standalone Notifier
-------------------

`notice = Notice.create(originName, defaultMiddleware)`

### Overview

```coffee

#
# Create a notifier with default middleware
# -----------------------------------------
# 
#  * If $HOME/.notice/middleware.js defines middleware
#    for the same originName it will override this 
#    default middleware. 
# 
#    see 'Local Environment Middleware' below
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

```


### Local Environment Middleware

Per user / daemon middleware can be defined at `$HOME/.notice/middleware.js`, [(example)](https://github.com/nomilous/notice/blob/master/.notice/middleware.js).



Notifier Hub
------------

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
        port:     12345
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

            console.log 'from:', msg.context.origin, msg

            #
            # reply across the response pipeline
            #

            msg.reply.info 'title', {pay: 'load'}
            next()


```



The Notifier `with uplink`
--------------------------

```






```


Possible Future Features (still exploring)
------------------------------------------

* flood protection
* time in pipeline / backlog (introspection)
* as message receiver
* tasks and escalations (with persistor plugin / state machine)
* hubside pipeline promise
* acknowledgability / take (state)
* updatability
* resolvability            (state)
* expire / escalate        (state)

