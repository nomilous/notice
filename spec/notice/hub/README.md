### Creating a Notifier Hub

**next:** The Capsule [`../capsule`](../capsule)

#### The `Definition`

```coffee

notice = require 'notice'
Television = notice.hub # a factory
    
    client: 
        capsule: 
            start: {}

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
* Emitters for these capsule definitions are available in the hubside middleware `traversal.origin` and are therefore only available upon handling a capsule originating from the client.
* It is therefore up to the client to bootstrap the necessary protocol sequences.


#### The `capsule` subconfig

* Defines capsules that originate at the hub.
* Mechanisms for controlling which clients receive them have not been outlined.
* **This portion of the api is likely to change WITHOUT DEPRECATION WARNINGS**


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
* If specified and present, cert and key files an https server is created for the socket.io listener.

