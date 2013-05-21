require('nez').realize 'Notice', (Notice, test, it, should) -> 

    it 'exports config() function', (done) -> 

        Notice.configure.should.be.an.instanceof Function
        test done


    it 'is a notifier', (done) -> 

        Notice.configure 

            source: 'TEST'
            messenger: (message) -> 

                #
                # defaults inserted into message
                #

                message.source.ref.should.equal 'TEST'
                should.exist message.source.time

                message.key.should.equal 'value'
                test done


        Notice key: 'value'
