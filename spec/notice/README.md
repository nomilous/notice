
Hub and Client Configurables
----------------------------

### Creating a Notifier Hub

#### The `Definition`

```coffee

notice = require 'notice'
Television = notice.hub # a factory
    
    client: 
        capsule: 
            start: {}

```

#### The `client` subconfig

* Defines the set of capsules that this hub can send to attached clients.


#### The `instance`

```coffee

Television.create

    listen:  
        adaptor: 'socket.io'
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

                console.log traversal.origin
                next()


```

#### The `listen` subconfig

* Hub configuration should define a listen specification.
* socket.io is currenly the only available transport adaptor.
* It starts a socket.io server.
* [UNVERIFIED] An existing `httpServer` object (eg express) can be assigned for socket.io to piggyback onto.
* Otherwise a new http or https server will be created.
* If specified and present, cert and key lead socket.io listening on an https server.


### Creating a Notifier Client

#### The `Definition`

```coffee

notice = require 'notice'
TelevisionRemote = notice.client # a factory

    capsule: 

        channel: {}
        volume:  {}
        pause:   {}
        play:    {}
        ffwd:    {}

```

#### The `capsule` subconfig

* Capsules are created asynchronously.
* Each **capsule is assigned a uuid when it is created**. 
* `capsule._uuid`
* The uuid will be available to all local and remote middleware functions that receive this capsule as it traverses the system.
* The uuid is hidden from serializers and protected from changes once created.
* More on the [./capsule](./capsule)
* The creation sequence passes the capsule through a before hook (if defined).
* The hook receives the capsule **after property assignment** but **before uuid assignment**.


```coffee

module.exports.TelevisionRemote = notice.client
    
    capsule:
        ...
        play:
            before: (done, capsule) -> 

                #
                # do something to the play capsule before it is pushed
                # onto the middleware pipeline
                # 

                play._uuid = 'my own uuid'
                done()
        ...

```


#### The `instance`

```coffee
{TelevisionRemote} = require './the/definition/from/above'

TelevisionRemote.create 'Family Room',

    context: 
        supremeAuthority: 'Mother' unless Grandfather? or Saturday?

    connect: 
        adaptor:            'socket.io'
        url:                'https://localhost:10101'
        secret:             process.env.SECRET
        errorWait:          1000
        rejectUnauthorized: false # tolerate self sighned cert on serverside

    (err, theConnectedRemote) -> 

        #
        # callback receives theConnectedRemote as notifier,
        # or error
        #


```

#### The Title

* Should be unique. 
* The hub will not allow a second instance of the 'Family Room' television remote to connect.

#### The `context` subconfg

* The client sends the context object to the hub during the connection handshake.
* This becomes available in the `traversal.origin` object passed along all hubside middleware traversals that contain a capsule originating from this client.

#### The `connect` subconfg

* The connection specification sets paramaters used for connecting to the hub. 
* socket.io is currenly the only available transport adaptor.

#### The callback

* It receives the notifier or an error
* **It is only called after succesfully attaching to the hub**


Emitting Capsules
-----------------

### With a Node Style Callback Waiting

```coffee

theConnectedRemote.volume 'up', amount: 3, (err, capsule) -> 

    #
    # callback receives final capsule,
    # or err
    #

    #console.log capsule._uuid
    console.log capsule

    #
    # => { volume: 'up', amount: 3 }
    # 

    console.log capsule.all 

    #
    # => { _type: 'volume', volume: 'up', amount: 3 }
    # 

```

* Each message capsule first traverses all locally registered middleware.
* If it reaches the end of the pipeline it is sent to the hub.
* The callback is executed with the capsule after the hub ACK
* The callback is executed with err if any middlewares throw, or if the hub NAKs the capsule.

### With a Promise Waiting

```coffee

theConnectedRemote.volume( 'up', amount: 3 ).then(

    (capsule) -> console.log 'Hub acknowledged', capsule._uuid
    (error)   -> console.log error
    (notify)  -> console.log 'Notify', notify 

        # 
        # => Notify { _type: 'control', control: 'transmitted', capsule: ...
        # => Hub acknowledged 75fa0370-31ce-11e3-8fda-879806fe07a4
        # 

)

```

* Emitting a capsule with a promise waiting behaves similarly to the node style example but with an additional capacity to receive control notifications.


Using the middleware pipeline
-----------------------------

### Registering middleware

```coffee

hub.use 
    
    title: 'meaningful title'
    (next, capsule, traversal) -> 

        #
        # do something
        #

        next()

```
* Middleware requires a title.
* `hub.force()` to replace the middleware.



### The middleware function

```coffee

(next, capsule, traversal) -> 

    getSomethingFromADatabaseOrWhatever (err, something) -> 

        throw err if err?
        capsule.something = something
        traversal.origin.whateverIsPutHere = """

            * will still be here @ next capsule from same origin
            * for as long as the hub process is not restarted

        """
        next()

```

* Do some stuff and call `next()` when done.
* Possibly make ammendments to the capsule.
* The capsule does not continue to the next middleware until `next()` is called.
* Intentionally not calling `next()` is bad - the **pending** introspection subsystem will consider the middleware as a bottleneck. Use `next.cancel()`.


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
* has `.whateverWasPutThere` still present the next time a capsule from the same origin traverses the pipeline (does not ?yet! survive a hub process restart)

`traversal.peers` **pending consideration**

* enables hub middleware to route capsules between clients


#### throwing errors (or failing to catch them)

```coffee

π = new Error()

notice.use 
    
    title: 'Pied Pipeliner'
    (next) -> throw π

notice.event().then(
    
    (capsule) ->  # caspule does not reach the end of the pipeline
    (error)   ->  error == π
    (notfiy)  -> 

)

```


Management (REST api)
---------------------

### Hub Introspection and Middleware Performance Metrics

**pending consideration**

### Hotswapping Middleware

**pending consideration**

