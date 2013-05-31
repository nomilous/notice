require('nez').realize 'Factory', (Factory, test, context, should, os) -> 

    context 'create()', (it) -> 


        it 'requires config.messenger as a message handler', (done) -> 

            try
                
                new Factory.create()

            catch error 

                error.should.match /requires config\.messenger/
                test done



        it 'calls back with the notifier', (that) -> 

            RECEIVED = []

            Factory.create { 

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

                    RECEIVED[0].label.should.equal 'arg1 string'
                    RECEIVED[0].description.should.equal 'arg2 string'

                    test done



                that 'has a middleware registrar', (done) -> 

                    notify.use.should.be.an.instanceof Function
                    test done


                that 'passes the message through the registered middleware', (done) -> 


                    RECEIVED = []

                    notify.use (msg, next) -> 
                        

                        msg.and  = 'THIS'
                        next()

                    notify.use (msg, next) -> 

                        msg.also = 'THAT'
                        next()

                     
                    notify 'LABEL', 'DESCRIPTION'

                    setTimeout -> 

                        RECEIVED[0].content.label.should.equal 'LABEL'
                        RECEIVED[0].content.description.should.equal 'DESCRIPTION'

                        RECEIVED[0].and.should.equal 'THIS'
                        RECEIVED[0].also.should.equal 'THAT'
                        test done
                    

                    ,10 # give it a moment

