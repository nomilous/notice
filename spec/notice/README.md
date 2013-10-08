
Hub and Client Configurables
----------------------------


Creating a Notifier
-------------------

### The Client

```coffee

notice = require 'notice'
TelevisionRemote = notice.client

    capsules: 

        channel: {}
        volume:  {}
        pause:   {}
        play:    {}
        ffwd:    {}

```
The `TelevisionRemote` definition can now be used to create a notifier instance.

```coffee
{TelevisionRemote} = require './the/previous/block'

TelevisionRemote.create 'Family Room',

    context: 
        supremeAuthority: 'Mother' unless Grandfather? || Saturday?

    connect: 
        address:           'localhost'
        transport:         'https'
        port:               10101
        secret:             process.env.SECRET
        errorWait:          1000
        rejectUnauthorized: false # tolerate self sighned cert on serverside

    (err, remote) -> 

        #
        # callback receives the connected remote or error
        #

```

### The Hub

```coffee

notice = require 'notice'
Television = notice.hub

        #
        # requires the same capsule definitions as the client
        #

Television.create

    listen:  
        # server:  existingHttpServer
        # address: '0.0.0.0'
        port:    10101
        secret:  'right'
        cert:    __dirname + '/../../cert/develop-cert.pem'
        key:     __dirname + '/../../cert/develop-key.pem'

    (error, hub) ->

        #
        # callback receives listening hub or error
        # 


```


Emitting Capsules
-----------------

### Node style


### With promise




Using the middleware pipeline
-----------------------------

### Registering middleware


### The middleware function

```coffee

(next, capsule, context) -> 

    getSomethingFromADatabaseOrWhatever (err, something) -> 

        throw err if err?
        capsule.something = something
        next()

```

* Do some stuff and call `next()` when done.
* Possibly make ammendments to the capsule.
* The capsule does not continue to the next middleware until `next()` is called.
* Intentionally not calling next is OK - it means you don't want the capsule to continue further.
* Future versions may require calling next.cancel() to facilitate pipeline metrics and bottleneck detection.
* **Unintentionally not calling next is BAD**



#### the next function

The next function has some nested tools.

* `next.notify()` sends a payload back to the emitter's promise `(notify) ->`
* `next.reject(error)` terminates the middleware traversal (same as throw)

#### the capsule

TODO_LINK: capsule page

#### the context


#### throwing errors

Hub and Client Context / Continuity
-----------------------------------



Todo
====

Multiple Hubs and Capsule Switching / Routing
---------------------------------------------


Transport Abstraction
---------------------


Boomerang Capsule and Response Expectations
-------------------------------------------


Published Notifier Definitions (npm)
------------------------------------


System Dashboard
----------------


Managing Middleware (remote, hotswap)
-------------------------------------


Horizontal Scaling and High Availability
----------------------------------------

```











































































































```