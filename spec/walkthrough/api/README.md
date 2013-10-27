Api Walkthrough
---------------

### Start the GenericHub

```bash

#
# from the repo root
#

npm install # incase that was not already done
node_modules/.bin/node-dev spec/walkthrough/api/generic_hub.coffee

```
It should have started the API listeing at [http://127.0.0.1:9999](http://127.0.0.1:9999) (username is 'user', no password) and 2 hubs at non-specific port numbers.
```bash
   info  - socket.io started
   info  - socket.io started
API @ http://127.0.0.1:9999
HUB @ http://127.0.0.1:61485
HUB @ http://127.0.0.1:61486
{ '$tick': 'SlowTick', seq: 0 }
{ '$tick': 'SlowTick', seq: 1 }
{ '$tick': 'SlowTick', seq: 2 }
{ '$tick': 'SlowTick', seq: 3 }
{ '$tick': 'SlowTick', seq: 4 }
...
```

SlowTick is being logged by the first hub instance in [`./generic_hob.coffee`](./generic_hub.coffee)

### Get the list of running hubs

