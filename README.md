`npm install notice` 0.0.12 [license](./license)

**unstable**(ish) - api changes [will still occur](./spec/notice/hub#the-capsule-subconfig)

#### TODO 0.0.12

* `opts.tools.*` passed into middleware `traverse.tools.*` in lieu of post hotswapped scope
* 'hubs/:uuid:/tools/* available via API (expects tools to expose any useful properties / metrics for serialization, eg. dinkum stats)
* boomerang capsule (emitter callback/resolve only after full remote hub traversal, throw/reject the same, boomerang is the default, emitters now expecting a result should specify on capsule definition, said emitters receive the callback on hub ack)
* middleware description

notice
======

A communicator. Also for other stuff.


### The Guiding Epiphanies

* Middleware can be hot-swapped.
* Middleware is perfect for routing information streams.
* Their flow-control and sequencial subscribe-ability describes a dynamic assembly line.
* An assembly (or disassembly) line can abstractify object storage and retreival.


### Quick Faqts

* all examples use coffee-script
* docs @ [`./spec/notice`](./spec/notice)
* example (walkthrough) @ [`../notice-example`](../notice-example)

### Also, Important

* Objects traversing a middleware pipeline can overtake each other. 


### Guidelines for Contribution

* welcome
* coffee-script is zen-garden
* `cake dev` watches & compiles & tests (has holes re: running all tests)
* i have never used that pull request thingy, you may need to bare with me
* judging by the rest of github's magic, i suspect it will be really easy
* but i have a perplexing propensity to inexplicably struggle with easy
* catscan suggests it's my boredom avoidence gland,, abnormally inflamed
* dogscan just barked more than usual,, at the catscan
* mousescan right clicked,, and opened in new tab

### Also

* i am a notoriously infrequent inbox perambulator
* the precise direction that this codebase is going depends on many still very
* abstract ideas
* **it will follow the thread of inspiration above any particular plan**
* planning improves, inspiration invents
* venn diagrams show overlaps
* a glorious coincidence presents the moon and the sun as almost precisely identical in relative size
* it will only remain so for another 500 million years
