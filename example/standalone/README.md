#### Standalone Example

Requires coffee-script `npm install -g coffee-script`

```bash

./main

component_ONE received: { event: 'start', interval: 1000 }
component_TWO received: { event: 'start', interval: 1000 }
changed property: state { from: undefined, to: 'pending' }
changed property: state { from: 'pending', to: 'failed' }
on bus2: [Error: oh dear...]
changed property: state { from: undefined, to: 'pending' }
on bus2: {
  "progress": "2 of 2",
  "createdAt": "2013-10-02T21:52:38.088Z",
  "ok": 2
}
changed property: state { from: 'pending', to: 'done' }
after bus2: { ok: 2 }
component_ONE received: { event: 'stop' }
component_TWO received: { event: 'stop' }

```
