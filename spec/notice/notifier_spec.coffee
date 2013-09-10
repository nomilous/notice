# require('nez').realize 'Notifier', (Notifier, test, context, should, os) -> 

os       = require 'os'
Notifier = require '../../lib/notice/notifier'
should   = require 'should'

describe 'Notifier', -> 

    context 'create()', -> 


        it 'requires origin name', (done) -> 

            try 
                Notifier.create()

            catch error
                error.should.match /requires message origin as string/
                done()



        context 'returns a notifier', -> 

            it 'is used to send messages', (done) -> 

                notify = Notifier.create( 'Message Origin' )
                notify 'test message'
                done()


            it 'has a middleware registrar', (done) -> 

                notify = Notifier.create( 'Message Origin' )
                notify.use (msg, next) -> 
                    next()
                    done()
                notify 'test message'

                


            it 'can further classify the message with type', (done) -> 

                notify = Notifier.create( 'Message Origin' )
                notify.use (msg, next) -> 

                    msg.context.type.should.equal 'info'
                    done()
                    next()

                notify.info 'test message'

            

            it 'returns the message "promise tail" from middleware pipeline', (done) ->

                notify = Notifier.create( 'Message Origin' )
                notify.info.normal( 'message' ).then.should.be.an.instanceof Function
                done()


            it 'populates the tail resolver with the final message (post middleware)', (done) -> 

                notify = Notifier.create( 'Message Origin' )
                notify.info.normal( 'message' ).then (finalMessage) -> 

                    finalMessage.context.title.should.equal 'message'
                    finalMessage.context.origin.should.equal 'Message Origin'

                    done()

            it 'survives middleware exceptions'
            it 'enables tracable middleware'


            it 'passes the message through the registered middleware', (done) -> 

                notify = Notifier.create( 'Message Origin' )
                notify.use (msg, next) -> 
                    
                    msg.and  = 'THIS'
                    next()

                notify.use (msg, next) -> 

                    msg.also = 'THAT'
                    next()

                 
                notify.info.normal( 'TITLE', 'DESCRIPTION' ).then (msg) ->

                    msg.context.title.should.equal 'TITLE'
                    msg.context.description.should.equal 'DESCRIPTION'

                    msg.and.should.equal 'THIS'
                    msg.also.should.equal 'THAT'
                    done()

            it 'allows (once only) reg of middleware to run at the beginning of the pipeline', (done) -> 

                c = 0 
                n = Notifier.create 'test'

                n.use       (msg, next) -> msg.one   = ++c; next()
                n.use       (msg, next) -> msg.two   = ++c; next()
                n.first   = (msg, next) -> msg.start = ++c; next()
                n.use       (msg, next) -> msg.three = ++c; next()
                n.first   = (msg, next) -> msg.start = 'IGNORED'; next()

                n.info('test').then (msg) ->

                    #console.log  msg
                    msg.start.should.equal 1
                    done()


            it 'allows (once only) reg of middleware to run at the end of the pipeline', (done) -> 

                c = 0 
                n = Notifier.create 'test'

                n.use       (msg, next) -> msg.one   = ++c; next()
                n.last    = (msg, next) -> msg.end   = ++c; next()
                n.use       (msg, next) -> msg.two   = ++c; next()
                n.use       (msg, next) -> msg.three = ++c; next()
                n.last    = (msg, next) -> msg.end   = 'IGNORED'; next()

                n.info('test').then (msg) ->

                    #console.log  msg
                    msg.end.should.equal 4
                    done()


