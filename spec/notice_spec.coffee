require('nez').realize 'Notice', (Notice, test, context, should) -> 

    it = context

    context 'exports a configure method', (that) -> 


        that 'expects a hash of config', (done) -> 

            try 
                
                Notice.configure()

            catch error

                error.should.match /requires opts.source/
                test done


        that 'expects a callback to receive the configured notifier', (done) -> 

            try 
                
                Notice.configure source: 'TEST'

            catch error

                error.should.match /requires callback to receive configured notifier/
                test done


    context 'event message', (has) -> 

        MSG = null
        Notice.configure(
            source: 'TEST'
            messenger: (msg) -> 
                MSG = msg
            -> 
        )

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

    context 'info message', (has) -> 

        MSG = null
        Notice.configure(
            source: 'TEST'
            messenger: (msg) -> 
                MSG = msg
            ->
        )

        has 'helpers for info tenor', (done) -> 

            Notice.info.bad 'test failed'
            MSG.context.should.eql { type: 'info', tenor: 'bad' }
            test done
