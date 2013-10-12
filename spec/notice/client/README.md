### Creating a Notifier Client

**next:** Creating a Notifier Hub [`../hub`](../hub)

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
