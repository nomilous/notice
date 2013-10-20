### Changelog

#### 0.0.12

minimize possible capsule control properties colliding with storage system result callbacks

* notice.control() becomes notice.$$control(), control capsule payload similarly changed
    * to filter control capsules from the pipe `return next.cancel() if capsule.$$control?`
* notice.raw() becomes notice.$$raw(), for consistancy
    * remains hidden, permanence uncertain
* capsule.hidden and capsule.protected list properties become $$hidden and $$protected
* capsule._type becomes capsule.$$type
* capsule._uuid becomes capsule.$$uuid
* capsule.all becomes capsule.$$all

