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
           
            new NotifierFactory().create { 

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



    