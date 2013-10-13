[`../notice`](../notice)

Management (REST api)
---------------------

### Creating a Manageable Hub

```coffee

notice = require 'notice'
NetworkAlertRouter = notice.hub

    ... # other config

    introspector:

        level: 0  # none
        level: 1  # not none

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
            # callback true if authetic
            # error is ignored, it just reposts the 401
            # 

            callback null, true


hub = NetworkAlertRouter.create( ...

```


### Hub Introspection and Middleware Performance Metrics

**pending consideration**

### Hotswapping Middleware

**pending consideration**

### Starting a Hub Instance

**pending consideration***

