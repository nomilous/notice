require('nez').realize 'NotifierFactory', (NotifierFactory, test, context, should) -> 

    context 'create()', (it) -> 


        it 'requires config.messenger as a message handler', (done) -> 

            try
                
                new NotifierFactory().create()

            catch error 

                error.should.match /requires config\.messenger/
                test done



        it 'calls back with the notifier', (that) -> 

            RECEIVED = []

            nf = new NotifierFactory()
            nf.create { 

                #
                # notifierFactory.create() takes a hash of 
                # config which must include a messenger
                # function
                #

                messenger: (message) -> RECEIVED.push message

                #
                # it calls back with a notifyier to 
                # send messages
                # 

            }, (error, notify) -> 



                that 'is used to send messages', (done) -> 

                    RECEIVED = []

                    notify 'test message'

                    should.exist RECEIVED[0]
                    test done



                that 'formats the message', (done) -> 

                    RECEIVED = []

                    notify 'arg1 string', 'arg2 string'

                    RECEIVED[0].content.should.eql
                        label:       'arg1 string'
                        description: 'arg2 string'

                    test done



                that 'has a middleware registrar', (done) -> 

                    middleware1 = (msg, next) -> msg.propery1 = 'value1' and next( msg )
                    middleware2 = (msg, next) -> msg.propery2 = 'value2' and next( msg )

                    notify.use middleware1
                    notify.use middleware2

                    nf.pipeline[0].should.equal middleware1
                    nf.pipeline[1].should.equal middleware2

                    test done


                that 'throws if the middleware does not persist the pipeline', (done) -> 

                    try
                        
                        notify.use (msg, next) -> 

                            msg.some  = 'thing'
                            msg.other = 'stuff'

                    catch error

                        error.should.match /terminal middleware detected/
                        test done






    