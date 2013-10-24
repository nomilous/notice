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
    # introspector:
    #     level: 0  # none
    #     level: 1  # not none
    # 
    # introspection stats by capsule/middleware not yet implemented
    # 

    manager:
        listen: 
            # hostname: 'localhost'
            port: 11011
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

**pending consideration**

### Hotswapping Middleware

**pending consideration**

* first middleware can queue for upgrade duration

### Starting a Hub Instance

**pending consideration**





### todo document fragments

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

