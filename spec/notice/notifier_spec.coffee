{_notifier, notifier} = require '../../lib/notice/notifier'
should   = require 'should'

describe 'notifier', -> 

    context 'factory', -> 

        it 'creates the Notifier object', (done) -> 

            Notifier = notifier()
            done()


        it 'allows message type definitions', (done) -> 

            Notifier = notifier
                messages: 
                    event:       {}
                    info:        {}
                    alert:       {}
                    assign:      {}
                    mollycoddle: {}
                    placate:     {}


            instance = Notifier.create 'originCode'

            should.exist _notifier().messageTypes.event
            should.exist _notifier().messageTypes.info
            should.exist _notifier().messageTypes.alert
            should.exist _notifier().messageTypes.assign
            should.exist _notifier().messageTypes.mollycoddle
            should.exist _notifier().messageTypes.placate
            done()



    context 'create()', -> 

        beforeEach -> 
            @now = Date.now

        afterEach -> 
            Date.now = @now


        it 'requires an originCode', (done) -> 

            Notifier = notifier()

            try Notifier.create()
            catch error
                error.should.match /requires originCode as string/
                done()


        it 'creates a function to send each defined message type', (done) ->

            Date.now = -> 'wrist watch'

            Notifier = notifier 
                messages:
                    pheeew: 
                        properties:
                            sourceHost: 
                                hidden:  true
                                default: require('os').hostname()
                        afterCreate: (msg, done) ->

                            #
                            # eg. push the new message to a database
                            #     before sending it.
                            #

                            msg.id        = 'new database record id'
                            msg.createdAt = Date.now() 
                            done()


            instance = Notifier.create 'originCode'
            instance.pheeew

                defcon:  1
                change: -4

            .then (newMessage) -> 

                newMessage.should.eql 

                    _type:     'pheeew'
                    id:        'new database record id'
                    createdAt: 'wrist watch'
                    defcon:     1
                    change:     -4

                #console.log newMessage.sourceHost
                done()


        it 'creates middleware storage and throws on duplicate originCode', (done) -> 

            Notifier = notifier()
            Notifier.create 'bakery'
            try Notifier.create 'bakery'
            catch π

                should.exist _notifier().middleware.bakery
                π.should.match /is already defined/
                done()


        it 'provides middleware registrar', (done) -> 

            Notifier = notifier
                messages:
                    use: 'this message definition is ignored'

            nine = Notifier.create 'Assembly Line 9'

            nine.use.should.be.an.instanceof Function
            done()


        it 'registers anonymous middleware with a sequence number', (done) -> 

            eight = notifier().create 'Assembly Line 8'
            eight.use (msg, next) -> 

                ### a middleware function ###
                next()

            eight.use (msg, next) -> 'SECOND MIDDLEWARE'

            m1 = _notifier().middleware['Assembly Line 8'][1]
            m1.should.be.an.instanceof Function
            m1.should.match /a middleware function/

            m2 = _notifier().middleware['Assembly Line 8'][2]
            m2().should.equal 'SECOND MIDDLEWARE'
            done()


        it 'throws on titled middleware registration without title and fn', (done) -> 

            seven = notifier().create 'Assembly Line 7'
            try seven.use 
                titel: 'troubled speller'
                fn: (msg, next) ->
            catch error
                error.should.match /requires middleware.title and middleware.fn/
                done()


        it 'registers titled middleware', (done) -> 

            six = notifier().create 'Assembly Line 6'
            six.use 
                title: 'arrange into single file'
                fn: (msg, next) -> next()
            six.use
                title: 'squirt the product in'
                fn: (msg, next) -> next()
            six.use
                title: 'put a lid on it'
                fn: (msg, next) -> next()

            mmm = _notifier().middleware['Assembly Line 6']

            mmm['arrange into single file'] {}, ->
            mmm['squirt the product in']    {}, ->
            mmm['put a lid on it']          {}, done
        

        it 'sequence is preserved when replacing middleware', (done) -> 

            {sequence, deferred} = require 'also'
            five = notifier().create 'Assembly Line 5'
            five.use (msg, next) -> 
                msg.array.push 1
                next()
            five.use 
                title: 'REPLACE ME'
                fn: (msg, next) -> 
                    msg.array.push 2
                    next()
            five.use 
                title: 'x'
                fn: (msg, next) -> 
                    msg.array.push 3
                    next()
            five.use 
                title: 'REPLACE ME'
                fn: (msg, next) -> 
                    msg.array.push 'new 2'
                    next()

            mmm = _notifier().middleware['Assembly Line 5']
            msg = array: []
            sequence( for key of mmm
                do (key) -> deferred ({resolve}) ->    
                    mmm[key] msg, resolve
            ).then ->

                msg.array.should.eql [1, 'new 2', 3]
                done()


return
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


