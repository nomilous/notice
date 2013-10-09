
Hub and Client Configurables
----------------------------

### Creating a Notifier Hub

```coffee

notice = require 'notice'
Television = notice.hub()
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

        hub.use 
            
            title: 'middleware title'
            (next, capsule, traversal) -> 

                next()


```

#### The Listen Spec

* Hub configuration should define a listen specification.
* It starts a socket.io server.
* An existing `httpServer` object (eg express) can be assigned for socket.io to piggyback onto.
* Otherwise a new http or https server will be created.
* If specified and present, cert and key lead to the creation of an https server.



### Creating a Notifier Client

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

#### The Title

* Should be unique. 
* The hub will not allow a second instance of the 'Family Room' television remote to connect.

#### The Context

* The client sends the context object to the hub during the connection handshake.
* This becomes available in the `traversal.origin` object passed along all hubside middleware traversals that contain a capsule originating from this client.

#### The Connect Spec

* The connection specification sets paramaters used for connecting to the hub. 
* Both https and http are using socket.io to facilitate the transport. 


Emitting Capsules
-----------------

### Node style


### With promise




Using the middleware pipeline
-----------------------------

### Registering middleware


### The middleware function

```coffee

(next, capsule, traversal) -> 

    getSomethingFromADatabaseOrWhatever (err, something) -> 

        throw err if err?
        capsule.something = something
        next()

```

* Do some stuff and call `next()` when done.
* Possibly make ammendments to the capsule.
* The capsule does not continue to the next middleware until `next()` is called.
* Intentionally not calling `next()` is BAD - the introspection subsystem will consider the middleware as a bottleneck. Use `next.cancel()`.


#### the next function

The next function has some nested tools.

* TODO: `next.cancel()` suspends further traversol of the pipeline.
* `next.notify(payload)` sends a payload back to the emitter's promise notify function. Emitters with a node style callback waiting have no mechanism to receive these notifications.
* `next.reject(error)` terminates the middleware traversal (same as throw)

#### the capsule

TODO_LINK: capsule page

#### the traversal object

`traversal.origin`

* has `.title` of the remote notifier that created the currently traversing capsule
* has `.context` containing the context of the capsule's origin as defined in `opts.context` at the remote notifiers initialization. 
* has `.connection` with basic details about the origins connection state.
* has `.whateverWasPutThere` still present the next time a capsule from that same origin traverses the pipeline (ie. It is a place to accumulate per client hubside state)



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