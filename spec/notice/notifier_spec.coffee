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

                # console.log newMessage
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
                (msg, next) ->
            catch error
                error.should.match /requires opts.title and fn/
                done()


        it 'registers titled middleware', (done) -> 

            six = notifier().create 'Assembly Line 6'
            six.use 
                title: 'arrange into single file'
                (msg, next) -> next()
            six.use
                title: 'squirt the product in'
                (msg, next) -> next()
            six.use
                title: 'put a lid on it'
                (msg, next) -> next()

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
                (msg, next) -> 
                    msg.array.push 2
                    next()
            five.use 
                title: 'x'
                (msg, next) -> 
                    msg.array.push 3
                    next()
            five.use 
                title: 'REPLACE ME'
                (msg, next) -> 
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

        it 'returns the promise of a message traversing the middleware pipeline', (done) -> 

            Notifier = notifier 
                messages:
                    makeThing: 
                        beforeCreate: (msg, done) ->
                            msg.serialNo = '0000000000001'
                            done()

            four = Notifier.create 'Assembly Line 4'
            four.use (msg, next) -> 
                msg.step1 = 'done'
                next()
            four.use title: 'step2', (msg, next) ->
                msg.step2 = 'done'
                next()

            four.makeThing

                colour: 'red'

            .then (result) -> 

                result.should.eql

                    serialNo: '0000000000001'
                    colour: 'red'
                    _type: 'makeThing'
                    step1: 'done'
                    step2: 'done'

                done()


        it 'rejects on failing middleware', (done) -> 

            Notifier = notifier messages: info: {}
            broken = Notifier.create 'broken pipeline'
            broken.use (msg, next) -> 
                throw new Error 'ka-pow!'
                next()

            broken.info().then (->), (error) ->

                error.message.should.equal 'ka-pow!'
                done()


        it 'has mech for first and last middlewares for hub and client'


