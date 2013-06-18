require('nez').realize 'Notice', (Notice, test, it, should) -> 


    it 'is a (messaging|????ing) middleware pipeline', (done) -> 


        #
        # create the notifier / pipeline input
        #

        notice = Notice.create 'Origin System'


        #
        # register some middleware
        #

        notice.use (msg, next) -> 

            msg.key1 = 'VALUE1'
            next()

        notice.use (msg, next) -> 

            msg.key2 = 'VALUE2'
            next()



        #
        # send an event down the pipeline
        #

        sent = notice.event.good 'title', 'description'



        #
        # it returned a promise 
        #

        sent.then( 

            (finalMessage) -> 

                finalMessage.content.should.eql

                    context:
                        title:       'title'
                        description: 'description'
                        origin:      'Origin System'
                        type:        'event'
                        tenor:       'good'

                    payload:
                        key1: 'VALUE1'
                        key2: 'VALUE2'

                test done


            (error) -> 

        )


    it 'allows multiple sources', (done) -> 

        source1 = Notice.create 'Source 1'
        source2 = Notice.create 'Source 2'

        MESSAGES = {}

        source1.use (msg, next) -> 

            MESSAGES[msg.context.origin] = msg
            next()

        source2.use (msg, next) -> 

            MESSAGES[msg.context.origin] = msg
            next()

        sent1 = source1.event.good 'title', 'description'
        sent2 = source2.event.good 'title', 'description'

        sent2.then -> 

            should.exist MESSAGES['Source 1']
            should.exist MESSAGES['Source 2']
            test done


