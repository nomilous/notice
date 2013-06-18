notice
======

messaging middleware pipeline

### Version 0.0.7 - (unstable)

`npm install notice`


The Notifier
------------

```coffee

Notice.create( originName )

```

### Overview

```coffee

Notice = require 'notice'
notice = Notice.create 'Origin Name'

notice.info 'message title', 'message description'

notice.event 'title', {

    description: 'description'
    more: ['th','ings']

}

```

### Middleware


```coffee

Notice = require 'notice'
notice = Notice.create 'Origin Name'

notice.use (msg, next) -> 

    console.log msg.content
    next()

```


### Local Environment Middleware


[$HOME/.notice/middleware.js](https://github.com/nomilous/notice/blob/master/.notice/middleware.js)





Possible Future Features (still exploring)
------------------------------------------

* flood protection
* time in pipeline / backlog (introspection)
* as message receiver
* tasks and escalations (with persistor plugin)
* acknowledgability
* resolvability

