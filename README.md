`npm install notice` 0.0.12 [license](./license)

**unstable**(ish) - api changes [will still occur](./spec/notice/hub#the-capsule-subconfig)

#### TODO 0.0.12

* `opts.tools.*` passed into middleware `traverse.tools.*` in lieu of post hotswapped scope
* 'hubs/:uuid:/tools/* available via API (expects tools to expose any useful properties / metrics for serialization, eg. dinkum stats)
* boomerang capsule (emitter callback/resolve only after full remote hub traversal, throw/reject the same, boomerang is the default, emitters now expecting a result should specify on capsule definition, said emitters receive the callback on hub ack)
* middleware description

notice
======

A communicator.


### The Guiding Epiphanies

* Middleware can be hot-swapped.
* Middleware is perfect for routing information streams.
* Their flow-control and sequencial subscribe-ability describes a dynamic assembly line.
* An assembly (or disassembly) line can abstractify object storage and retreival.


### Quick Faqts

* all examples use coffee-script
* coffee-script is zen-garden
* `cake dev` watches & compiles & tests
* docs @ [`./spec/notice`](./spec/notice)
* [example (walkthrough)](https://github.com/nomilous/notice-example)

### Also, Important

* Objects traversing a middleware pipeline can overtake each other. 

