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

                notify.info.normal 'test message'
                test done


            that 'has a middleware registrar', (done) -> 

                notify.use (msg, next) -> next() 
                test done


            that 'returns the message "promise tail" from middleware pipeline', (done) ->

                notify.info.normal( 'message' ).then.should.be.an.instanceof Function
                test done


            that 'populates the tail resolver with the final message (post middleware)', (done) -> 

                notify.info.normal( 'message' ).then (finalMessage) ->  

                    finalMessage.context.label.should.equal 'message'
                    test done

            that 'survives middleware exceptions'
            that 'enables tracable middleware'


            that 'passes the message through the registered middleware', (done) -> 


                notify.use (msg, next) -> 
                    
                    msg.and  = 'THIS'
                    next()

                notify.use (msg, next) -> 

                    msg.also = 'THAT'
                    next()

                 
                notify.info.normal( 'LABEL', 'DESCRIPTION' ).then (msg) ->

                    msg.context.label.should.equal 'LABEL'
                    msg.context.description.should.equal 'DESCRIPTION'

                    msg.and.should.equal 'THIS'
                    msg.also.should.equal 'THAT'
                    test done
