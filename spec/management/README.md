[`../notice`](../notice)

Management (REST api)
---------------------

### Creating a Manageable Hub

```coffee

notice = require 'notice'
NetworkAlertRouter = notice.hub

    ... # other config

    
    error:
        keep: 10  # oldest first

        #
        # TODO: 
        # 
        # proceed: true  (capsule keeps going despite errors)
        # notify:  true  (error notified back to the emitter promise.notify)
        # append:  true  (error appended into casule, bus.uuid, mware.title and .description included)
        # 

    #
    # introspector:
    #     level: 0  # none
    #     level: 1  # not none
    # 
    # introspection stats by capsule/middleware not yet implemented
    # 

    manager:
        listen: 
            # hostname: 'localhost'
            port: 20002
            key:  '/path/to/key'
            cert: '/path/to/cert'

        # 
        # authenticate: username: 'nomilous', password: '∆'
        # 
        # or: 
        # 

        authenticate: (username, password, callback) -> 

            #
            # perform upstream authentication
            # NB: callback null if not authetic
            # (anthenticatedEntity will likely come in handly later) ##undecided1
            # error is ignored, it just reposts the 401
            # 

            callback null, username: username


hub = NetworkAlertRouter.create( ...

```




### Hub Introspection and Middleware Performance Metrics


`curl -u user: :20002/v1/hubs`
```json 
{
  "1": {
    "title": "Message Bus Title",
    "uuid": 1,
    "stats": {
      "pipeline": {
        "input": {
          "count": 36
        },
        "processing": {
          "count": 0
        },
        "output": {
          "count": 36
        },
        "error": {
          "usr": 0,
          "sys": 0
        },
        "cancel": {
          "usr": 0,
          "sys": 0
        }
      }
    }
  }
}
```


`curl -u user: :20002/v1/hubs/1/middlewares/1`
```json 
{
  "slot": 1,
  "title": "initializer",
  "description": "First middleware is usefull for filtering builtin control capsules.",
  "type": "usr",
  "enabled": true
}
```


**pending consideration**

### Hotswapping Middleware

**pending consideration**

* first middleware can queue for upgrade duration

### Starting a Hub Instance

**pending consideration**





### todo document fragments

