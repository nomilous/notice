#### Standalone Example

Requires coffee-script `npm install -g coffee-script`

```bash

./main

component_ONE received: { run: {} }
component_TWO received: { run: {} }
on bus2: [Error: oh dear...]
on bus2: {
  "progress": "2 of 2",
  "createdAt": "2013-10-01T20:12:27.066Z",
  "ok": 2
}
after bus2: { ok: 2 }
component_ONE received: { stop: {} }
component_TWO received: { stop: {} }


```
