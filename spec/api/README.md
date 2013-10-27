[`../notice`](../notice)

rough docs:

Management API
--------------

### Creating a Manageable Hub

```coffee

notice = require 'notice'
NetworkAlertRouter = notice.hub

    ... # other config

    api:
        listen: 
            # hostname: 'localhost'
            port: 20002
            # key:  '/path/to/key'
            # cert: '/path/to/cert'
            # recommend nginx for this

        # 
        # authenticate: 
        #     username: 'nomilous'
        #     password: '∆'
        #     anything: 'else'
        # 
        # or: 
        # 

        authenticate: (username, password, callback) -> 

            #
            # * perform upstream authentication (and probably role collection)
            # * NB: callback null if not authetic
            #   (anthenticEntity will likely come in handly later) ##undecided1
            # * error is ignored, it just reposts the 401
            # * each request is required to provide authentication, 
            #   no session support yet
            # 

            callback null, 
                username: username
                roles: ['bedtime story teller']


    #
    # introspector:
    #     level: 0  # none
    #     level: 1  # not none
    # 
    # introspection stats by capsule/middleware not yet implemented
    # 



hub = NetworkAlertRouter.create( ...

```

### Hub Introspection and Middleware Performance Metrics


`curl -u user: :20002/hubs`
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


`curl -u user: :20002/hubs/1/middlewares/1`
```json 
{
  "slot": 1,
  "title": "initializer",
  "description": "First middleware is usefull for filtering builtin control capsules.",
  "type": "usr",
  "enabled": true
}
```

```bash
curl -u user: -H 'Content-Type: text/coffeescript' :20002/hubs/1/middlewares -d '

title: "title"
slot:  1
fn: (next) -> next()

'
```
```json
{
  "error": {
    "type": "Error",
    "message": "notice: cannot insert middleware with specified slot",
    "suggestion": {
      "upsert": "[POST,PUT] /hubs/:uuid:/middlewares/:slot:"
    }
  }
}
```


**pending consideration**

### Hotswapping Middleware

**pending consideration**

* first middleware can queue for upgrade duration

### Starting a Hub Instance

**pending consideration**





### todo document fragments
