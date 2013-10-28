REST Api Walkthrough
--------------------

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

```bash

curl -u user: localhost:9999/hubs

```
```json
{
  "1": {
    "title": "Bus 1",
    "uuid": 1,
    "stats": {
      "pipeline": {
        "input": {
          "count": 50    <---------- The number of capsules that have been 
        },                           inserted into the middleware pipeline.
        "processing": {
          "count": 0     <---------- The number of capsules currently
        },                           traversing the pipeline.
        "output": {
          "count": 50    <---------- The number that have ^^successfully^^
        },                           completed their traversal.
        "error": {
          "term": {      <---------- Errors that terminated the traversal.
            "usr": 0,                (all errors currenly do)
            "sys": 0
          }
          "pass": { 
            "usr": 0,
            "sys": 0
          }
        },
        "cancel": {
          "usr": 0,
          "sys": 0
        }
      }
    }
  },
  "2": {
    "title": "Bus 2",
    "uuid": 2,
    "stats": {
      "pipeline": {
        "input": {
          "count": 34240  <--------- Bigger number. There is a faster ticker
        },                           configured on Bus 2.
        "processing": {
          "count": 0
        },
        "output": {
          "count": 34240
        },
        "error": {
          "term": {
            "usr": 0,
            "sys": 0
          },
          "pass": {
            "usr": 0,
            "sys": 0
          }
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

### Drill into the stats for hub 2 in a watch loop

```bash

watch -n 1 curl -su user: localhost:9999/hubs/2/stats

#
# perhaps leave that running while you create a fake workload
#

```

### Create a fake workload on Bus 2

This posts a new middleware that pretends to take a short while to do it's job.

```bash
curl -w "\n%{http_code}" -u user: -H 'Content-Type: text/javascript' localhost:9999/hubs/2/middlewares -d '
{ 
    title: "Fake workload middleware",
    fn: function(next) {
        setTimeout(function() {

            /*
             *  The capsule (in this case a tick) does not proceed 
             *  to the next middleware until this one calls next.
             # 
             *  Next is delayed here for 10 seconds.
             *    
             */

            next();
        }, 10000);
    }
}
'

```
```json
{
  "slot": 1,
  "title": "fake workload",
  "type": "usr",
  "enabled": true
}
201  <-------- (CREATED)
```

### Disable the new middleware

Using the slot number from the insert result above, send instruction to disable the newly inserted middleware. The processing count should fall back down to zero over the course of ten seconds. 

Once it reaches zero the input and output counts should once again match up.

```bash

curl -u user: localhost:9999/hubs/2/middlewares/1/disable
curl -u user: localhost:9999/hubs/2/middlewares/1/enable

```

### Moonwalk the Tree

```shell

curl -u user: localhost:9999/hubs/2/middlewares/1/fn
curl -u user: localhost:9999/hubs/2/middlewares/1
curl -u user: localhost:9999/hubs/2/middlewares
curl -u user: localhost:9999/hubs/2

```

### Post broken middleware (syntax error)

```bash
curl -w "\n%{http_code}" -u user: -H 'Content-Type: text/javascript' localhost:9999/hubs/2/middlewares -d '
{ 
    title: "Does not evaluate an Javascript",
    fn: function(next) {
        ;)
    }
}
'
```
```json
{
  "error": {
    "type": "SyntaxError",
    "message": "Unexpected token )"
  }
}
400
```

### Post broken middleware (runtime error)

```bash
curl -w "\n%{http_code}" -u user: -H 'Content-Type: text/javascript' localhost:9999/hubs/2/middlewares -d '
{ 
    title: "Broken Middleware Title",
    fn: function(next) {
        erm++;
    }
}
'
```

### View the recent error history

```bash
curl -su user: localhost:9999/hubs/2/errors | head -n 20
```
```json
{
  "term": {
    "recent": [
      {
        "timestamp": "2013-10-28T17:31:04.824Z",
        "error": "ReferenceError: erm is not defined",
        "middleware": {
          "title": "Broken Middleware Title",
          "type": "usr"
        }
      },
      {
        "timestamp": "2013-10-28T17:31:04.826Z",
        "error": "ReferenceError: erm is not defined",
        "middleware": {
          "title": "Broken Middleware Title",
          "type": "usr"
        }
      },
      {
```
* The watch loop on http://localhost:9999/hubs/2/stats should also begin accumulating the error count
* See `config.error.keep` in the hub definition.
* If the **Fake workload middleware is active** the errors would not have begun to appear for ten seconds.
* The accumulated errors cannot be flushed (orsomesuchthing, yet). They remain present for as long as the process remains running.






