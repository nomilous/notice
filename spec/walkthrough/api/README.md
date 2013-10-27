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
It should have started the API listeing [http://127.0.0.1:9999](http://127.0.0.1:9999) at and 2 hubs at non-specific port numbers.
```bash
   info  - socket.io started
   info  - socket.io started
API @ http://127.0.0.1:9999
HUB @ http://127.0.0.1:61485
HUB @ http://127.0.0.1:61486
```

### Get the list of running hubs

