### Changelog

#### 0.0.12

minimize possible capsule control properties and functions colliding with storage system result callbacks or possible desired property names.

* notice.control() becomes notice.$$control(), control capsule payload similarly changed
    * to filter control capsules from the pipe `return next.cancel() if capsule.$$control?`
* notice.raw() becomes notice.$$raw(), for consistancy
    * remains hidden, permanence uncertain
* capsule.hidden and capsule.protected list properties become $$hidden and $$protected
* capsule._type becomes capsule.$$type
* capsule._uuid becomes capsule.$$uuid
* capsule.all becomes capsule.$$all
* capsule.set() becmomes capsule.$$set()

fix bump encountered when syncing database records into an elasticsearch cluster

* added config.capsule.type_def.nondescript for special cases requiring capsule.type_def 'value' to not be enumerated at serialization 

middleware description 

* added opts.description support to notice.use() and notice.force() middleware registrars
    * registrars continue to ignore all but description, enabled
    * metrics remains an untouchable empty hash pending introspector

tools

* nested tools hash into notifier searialization
* available at traversal.tools.* and api hubs/:uuid:/tools/**/*

stats

* renamed metrics to stats in api

middleware

* middleware can be inserted at other than slot 1 (to intentionally leave gaps in the sequence, for emergencies)
* middleware listed in api `V1/hubs/:uuid:/middlewares`
* middleware accessable at slot number in api `V1/hubs/:uuid:/middlewares/:slot:`
* POST /hubs/:uuid:/middlewares to insert middleware onto the pipeline's tail 
* removed /v1 from api paths
