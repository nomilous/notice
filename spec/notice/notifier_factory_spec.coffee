require('nez').realize 'NotifierFactory', (NotifierFactory, test, context, should) -> 

    context 'create()', (it) -> 


        it 'requires config.messenger as a message handler', (done) -> 

            try
                
                new NotifierFactory().create()

            catch error 

                error.should.match /requires config\.messenger/
                test done



        it 'calls back with the message generator', (done) -> 


            myMessageHandler = (message) -> 

                message.should.equal 'test message'
                test done


            new NotifierFactory().create { 

                messenger: myMessageHandler

            }, (error, notify) -> 


                notify 'test message'
                
    