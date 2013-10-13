Drone Farm
----------

### currently impossible, pending

* transport adaptor that supports more than one client connection
* boomerang capsule

#### client 

* emits job capsules to the `job despatch` hub

#### job dispatch (hub)

* fronts arbitrary number of worker hubs
* middleware routes jobs to workers and load balances
* `clients` attach as client
* api pushs job definitions into the farm

#### worker (hub)

* `job despatch` attaches as client

