require('nez').realize 'Notice', (Notice, test, it, should) -> 

    it 'is a messaging middleware pipeline', (done) -> 


        notice = Notice.create 'Origin System'


        notice.use (msg, next) -> msg.key1 = 'VALUE1'; next()
        notice.use (msg, next) -> msg.key2 = 'VALUE2'; next()


        sent = notice.event.good 'title', 'description'


        sent.then (msg) -> 

            msg.should.eql 
                key1: 'VALUE1'
                key2: 'VALUE2'

            msg.context.should.eql 
                title:       'title'
                description: 'description'
                origin:      'Origin System'
                type:        'event'
                tenor:       'good'

            test done

    