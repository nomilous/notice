The Capsule
-----------

**next:** Emitting Capsules [`../`](../)

### Quick Faqts

* The **first** `key:'value'` passed to `capsule.set()` is the one that sets the property.
* A property cannot be watched AND protected. (Does it even make sense to want that?)
* `caspule.all` enumerates all properties, **including hidden ones**.
* `capsule.all` does not enumerate in created order.


### Watched properties

* Can assign a callback to receive notification of a propery change.
* The watching listener is not called once the capsule has been emitted to the hub.
* Useful as a **comms.** *back-channel* to some previous middleware in the pipeline.
* Keep in mind that middleware are run in the same sequence that they were registered.

```coffee

notifier.use

    title: 'resaver'
    (next, capsule) -> 

        capsule.set

            needsSave: false
            hidden:    true
            watched: (change) -> 

                #
                # * this will now be called whenever a middleware further down the 
                #   pipeline updates capsule.needsSave
                # 
                # * the `change.capsule` is a reference to the capsule, it should
                #   not be assumed that the content of the capsule remains static
                #   for the period between the setting of the needsSave flag and
                #   the running of this callback.
                #

                return unless change.to # == true

                if change.capsule._type.match /ticket|escalation|resolution/

                    #
                    # perform save to database of choice
                    # ----------------------------------
                    # 
                    # * it probably makes more sense to place this functionality
                    #   in the capsule definition's before hook, along with the 
                    #   initial database create() call.
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
# ----------------------------
# 
# * suggests something is looping through unresolved tickets
#   and emitting them down this middleware pipeline.
# 

notifier.use

    title: 'update ticket'
    (next, capsule) -> 

        if capsule._type == 'ticket'

            return pollVariousSourcesForMaybeTheProblemCanEvenFixItself (err, res) -> 

                #
                # apply possible changes to capsule
                #

                capsule.needsSave = true
                next()

        next()

# 
# * still receiving the change notification even after sending the 
#   capsule to a remote process is a posibility not yet realized.
# 

```

### Hidden properties

* In the example above, `needsSave` was set to hidden so that serialization of the capsule would not include it.
* It would not be very practically appropriate if the `needsSave` property also got saved... `(;`
* Aaah yes, one more thing. The hidden properties can be found out...

```coffee

notifier.use

    title: 'nosey middleware'
    (next, capsule) -> 

        console.log key, capsule[key] for key of capsule._hidden
        next()

```
* ...and unhidden.

```coffee

notifier.use

    title: 'snowsey middleware'
    (next, capsule) -> 

        capsule.set 
            secret: capsule.secret
            hidden: false

        next()

```

### Protected properties

* Creates properties that cannot be modified further.
* Sounds possibly paranoid, but applications grow, and their intricacy grows even faster...
* Protection - may help prevent interesting mistakes.
* Protection - *puts a condom over the new developer.*

```coffee

notifier.use

    title: 'assign route'
    (next, capsule) -> 

        #
        # complicated algorythm that results in important routingCode
        # and then...
        # 

        capsule.set routingCode: '™i', protected: true
        next()


```

[ok]() [cancel]() [schlierenize]()

