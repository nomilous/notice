Creating a Notifier
-------------------


Hub and Client Configurables
----------------------------


Emitting Capsules
-----------------

### Node style


### With promise




Using the middleware pipeline
-----------------------------

### Registering middleware


### The middleware function

* Do some stuff and call `next()` when done.
* Possibly make ammendments to the capsule.
* The capsule does not continue to the next middleware until `next()` is called.
* Intentionally not calling next is OK - it means you don't want the message to continue further.
* **Unintentionally not calling next is BAD**

```coffee

(next, capsule) -> 

    getSomethingFromADatabaseOrWhatever (err, something) -> 

        throw err if err?
        capsule.something = something
        next()

```

#### throwing errors

#### the next function

The next function has some nested tools.

* `next.notify()` sends a payload back to the emitter's promise `(notify) ->`

#### the capsule

TODO_LINK: capsule page



Hub and Client Context / Continuity
-----------------------------------



Todo
====

Multiple Hubs and Capsule Switching / Routing
---------------------------------------------


Transport Abstraction
---------------------


Boomerang Capsule and Response Expectations
-------------------------------------------


Published Notifier Definitions (npm)
------------------------------------


System Dashboard
----------------


Managing Middleware (remote, hotswap)
-------------------------------------


Horizontal Scaling and High Availability
----------------------------------------

```











































































































```