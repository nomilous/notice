The Capsule
-----------

### Watched properties

* Can assign a callback to receive notification of a propery change.
* Useful as a comms channel back to some previous middleware in the pipeline.
* Keep in mind that middleware are run in the same sequence that they were registered in.

#### eg. 


```coffee

notifier.use

    title:       'index'
    description: 'save selected capsules onto an elasticsearch cluster'
    (next, capsule) -> 

        capsule.set

            needsSave: false
            hidden:    true
            watched: (change) -> 

                if change.capsule._type.match /ticket|escalation|resolution/

                    #
                    # post to elasticsearch
                    #

                    #
                    # IMPORTANT: There is no `next()` for the change watcher
                    # 
                    #            And putting the `next()` for the middleware
                    #            inside the changewatcher will terminate the
                    #            capsule's middleware traversal.
                    #

        next()

```
```coffee

#
# elsewhere in the application
#

notifier.use

    title: 'update ticket'
    (next, capsule) -> 

        if capsule._type == 'ticket'

            return pollVariousSourcesForTicketUpdateInfo (err, res) -> 

                capsule.needsSave = true
                next()

        next()
```

...

### Hidden properties

...

### Protected properties

...


