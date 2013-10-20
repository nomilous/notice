#### Suggested First Readings

* [`./client`](./client) Creating a Notifier Client
* [`./hub`](./hub) Creating a Notifier Hub
* [`./capsule`](./capsule) The Capsule

Emitting Capsules
-----------------

### With a Node Style Callback Waiting

```coffee

theConnectedRemote.volume 'up', amount: 3, (err, capsule) -> 

    #
    # callback receives final capsule,
    # or err
    #

    #console.log capsule.$$uuid
    console.log capsule

    #
    # => { volume: 'up', amount: 3 }
    # 

    console.log capsule.$$all 

    #
    # => { $$type: 'volume', volume: 'up', amount: 3 }
    # 

```

* Each message capsule first traverses all locally registered middleware.
* If it reaches the end of the pipeline it is sent to the hub.
* TEMPORARY - The callback is executed with the final `capsule` after the hub ACK
* PENDING - The callback is executed with the final `capsule` after a full hubside middleware traversal.
* The callback is executed with err if any middlewares throw, or if the hub NAKs the capsule.

### With a Promise Waiting

```coffee

theConnectedRemote.volume( 'up', amount: 3 ).then(

    (capsule) -> console.log 'Hub acknowledged', capsule.$$uuid
    (error)   -> console.log error
    (notify)  -> console.log 'Notify', notify 

        # 
        # => Notify { $$type: 'control', $$control: 'transmitted', capsule: ...
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


#### the `next` function

The next function has some nested functions.

`next.notify(payload)` 
* Sends a payload back to the emitter's promise notify function. 
* Emitters with a node style callback waiting have no mechanism to receive these notifications.

`next.cancel()` 
* Suspends further traversal of the pipeline.
* Sends a cancel notification back to the emitter's promise notify function. 
* **It does not call an error into the waiting node style callback.**

`next.reject(error)`
* Terminates the middleware traversal.
* Calls the error back to the emitter promise/callback.

#### the `traversal` object

`traversal.origin`

* has `.title` of the remote notifier that created the currently traversing capsule
* has `.context` containing the context of the capsule's origin as defined in `opts.context` at the remote notifiers initialization. 
* has `.connection` with basic details about the origins connection state.
* has `.whateverWasPutThere` still present the next time a capsule from the same origin traverses the pipeline (does not ?yet! survive a hub process restart)

`traversal.cache`

* has a permanent reference to the `opts.cache` as assigned in `Hub.create(opts)`
* middlewares can populate this cache at will
* the same cache object is passed into all middleware traversals
* the cache content is available for remote veiwing on the REST api `/v1/hubs/:uuid:/cache`

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

* Thows or failiures to catch in middleware result in the traversal being terminated. 
* The offending error is called back at the emitter.
* PENDING Errors occuring on a remote hub have the same affect back at the origin emitter.
* A recent error history is preserved (config.error.keep:N) and available at `hub.serialize(2)`
* Error history is also available on the REST api `/v1/hubs/:uuid:/errors`
