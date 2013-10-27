### Creating a Notifier Hub

**next:** The Capsule [`../capsule`](../capsule)

### The `Definition` Factory

```coffee

notice = require 'notice'
Television = notice.hub
    
    client: 
        capsule: 
            start: {}

    #
    # TODO: 
    # 
    # parallel: true  (middleware is run in parallel)
    # 

    # #
    # # hubside capsule definition
    # # 
    #
    # capsule: 
    #    type_name: {}
    #


```

#### The `client` subconfig

* Defines the set of capsules that this hub can send to attached clients.
* Emitters for these capsule definitions are available in the hubside middleware `traversal.origin` object and are therefore only available upon handling a capsule originating from the client.
* It is therefore up to the client to bootstrap the necessary protocol sequences.


#### The `capsule` subconfig

* Defines capsules that originate at the hub.
* Mechanisms for controlling which clients receive them have not been outlined.
* **This portion of the api is likely to change WITHOUT DEPRECATION WARNINGS**


### The `instance`

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

    ticks:
        label:
            interval: 1000

    cache: {}
    tools: {}

    (error, hub) ->

        #
        # callback receives listening hub or error
        # 

        hub.use 
            
            title: 'middleware title'
            (next, capsule, traversal) -> 

                # traversal.cache
                # traveral.tools

                console.log traversal.origin
                next()


```

#### The `listen` subconfig

* Hub configuration should define a listen specification.
* socket.io is currenly the only available transport adaptor.
* It starts a socket.io server.
* [UNVERIFIED] An existing `httpServer` object (eg express) can be assigned for socket.io to piggyback onto.
* Otherwise a new http or https server will be created.
* If specified and present, cert and key files an https server is created for the socket.io listener.

#### The `ticks` subconfig

* Configures an interval timer to repeat emit a `$$tick` capsule into the pipeline
* It is recommended that ticks are `next()`ed immediately to proceed them to all middleware as close as possible to the time they happened.
* The `$$tick` capsule contains the configured label and a sequence number.

```coffee
capsule.$$tick == 'label'
typeof capsule.seq is 'number'
```

#### The `cache` subconfig

* Configures a hash (tree) that is accessable to all middleware in the pipeline.
* Middleware can modify the content of the cache via `traversal.cache`
* The cache is available via the api at `[GET] /hubs/:uuid:/cache[/**/*]`
* The cache is not persisted. Restart the hub, and it's gone!
* Why is there a cache tree? For [middleware scope](../middleware_scope.md).


#### The `tools` subconfig

* Similar to the `cache`. But for tools that the middleware may require.
* Available to middleware via `traversal.tools`
* Available via the api at `[GET] /hubs/:uuid:/tools[/**/*]`
* See [here](../../tools) for some additional tool functionality.
* Why is there a tools tree? For [middleware scope](../middleware_scope.md)

