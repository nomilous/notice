require('nez').realize 'Notice', (Notice, test, context, should) -> 

    it = context

    it 'exports config() function', (done) -> 

        Notice.configure.should.be.an.instanceof Function
        test done


    it 'is a notifier', (done) -> 

        Notice.configure 

            source: 'TEST'
            messenger: (message) -> 

                message.content.key.should.equal 'value'
                test done

        Notice key: 'value'



    context 'event messages', (has) -> 

        MSG = null
        Notice.configure 
            source: 'TEST'
            messenger: (msg) -> 
                MSG = msg

        has 'helpers for event tenor', (done) -> 

            Notice.event.good 'thing'
            MSG.context.should.eql 
                type: 'event'
                tenor: 'good'

            Notice.event.normal 'lunch', 'not a roast'
            MSG.context.should.eql 
                type: 'event'
                tenor: 'normal'

            Notice.event.bad 'the dish ran away WITHOUT the spoon', """

                consequences unknown
                TERMINATE SIMULATION

            """
            test done

