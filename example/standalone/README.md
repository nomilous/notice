#### Standalone Example

Requires coffee-script `npm install -g coffee-script`

```bash

./main

component_ONE received: { event: 'start', interval: 1000 }
component_TWO received: { event: 'start', interval: 1000 }
on bus2: [Error: oh dear...]
on bus2: {
  "progress": "2 of 2",
  "createdAt": "2013-10-01T21:42:58.553Z",
  "ok": 2
}
after bus2: { ok: 2 }
component_ONE received: { event: 'stop' }
component_TWO received: { event: 'stop' }

```
