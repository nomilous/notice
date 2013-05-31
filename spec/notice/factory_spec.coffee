require('nez').realize 'Factory', (Factory, test, context, should, os) -> 

    context 'create()', (it) -> 


        it 'requires origin name', (done) -> 

            try 
                Factory.create()

            catch error
                error.should.match /require message origin as string/
                test done


        it 'returns a notifier', (that) -> 

            RECEIVED = []
            notify = Factory.create( 'Message Origin' )


            that 'is used to send messages', (done) -> 

                notify 'test message'
                test done


            that 'has a middleware registrar', (done) -> 

                notify.use (msg, next) -> next() 
                test done


            that 'returns the promise tail from middleware pipeline', (done) ->

                notify( 'message' ).then.should.be.an.instanceof Function
                test done


            that 'populates the resolver with the final message (post middleware)', (done) -> 

                notify( 'message' ).then (finalMessage) ->  

                    console.log 'message: ----------->', finalMessage
                    finalMessage.content.label.should.equal 'message'
                    test done









            # that 'passes the message through the registered middleware', (done) -> 


            #     RECEIVED = []

            #     notify.use (msg, next) -> 
                    

            #         msg.and  = 'THIS'
            #         next()

            #     notify.use (msg, next) -> 

            #         msg.also = 'THAT'
            #         next()

                 
            #     notify 'LABEL', 'DESCRIPTION'

            #     setTimeout -> 

            #         RECEIVED[0].content.label.should.equal 'LABEL'
            #         RECEIVED[0].content.description.should.equal 'DESCRIPTION'

            #         RECEIVED[0].and.should.equal 'THIS'
            #         RECEIVED[0].also.should.equal 'THAT'
            #         test done
                

            #     ,10 # give it a moment

