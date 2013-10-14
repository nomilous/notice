{_notifier, notifier} = require '../../lib/notice/notifier'
should   = require 'should'

describe 'notifier', -> 

    context 'factory', -> 

        it 'creates a Notifier definition', (done) -> 

            Notifier = notifier()
            done()


        it 'allows capsule type definitions', (done) -> 

            Notifier = notifier
                capsule: 
                    event:       {}
                    info:        {}
                    alert:       {}
                    assign:      {}
                    mollycoddle: {}
                    placate:     {}


            instance = Notifier.create 'title'

            should.exist _notifier().capsuleTypes.event
            should.exist _notifier().capsuleTypes.info
            should.exist _notifier().capsuleTypes.alert
            should.exist _notifier().capsuleTypes.assign
            should.exist _notifier().capsuleTypes.mollycoddle
            should.exist _notifier().capsuleTypes.placate
            done()


        it 'creates event() as default capsule emitter if none defined', (done) ->  

            Notifier = notifier()
            instance = Notifier.create 'title'
            instance.event.should.be.an.instanceof Function
            done()

        it 'creates builtin control capsule emitter', (done) -> 

            Notifier = notifier capsule: userDefinedMessage: {}
            instance = Notifier.create 'title'
            instance.userDefinedMessage.should.be.an.instanceof Function
            instance.control.should.be.an.instanceof Function
            done()


    context 'create()', -> 

        beforeEach -> 
            @now = Date.now

        afterEach -> 
            Date.now = @now


        it 'requires a title', (done) -> 

            Notifier = notifier()

            try Notifier.create()
            catch error
                error.should.match /requires title as string/
                done()

        it 'is assigned a uuid', (done) -> 

            Notifier = notifier()
            n = Notifier.create 'title'
            should.exist n.uuid
            done()

        it 'uses a provided uuid', (done) -> 

            Notifier = notifier()
            n = Notifier.create 'title', 'uuid'
            n.uuid.should.equal 'uuid'
            done()


        it 'creates a function to send each defined capsule type', (done) ->

            Date.now = -> 'wrist watch'

            Notifier = notifier 
                capsule:
                    pheeew:  
                        before: (done, capsule) ->

                            #
                            # eg. push the new capsule to a database
                            #     before sending it.
                            #

                            capsule.id        = 'new database record id'
                            # or capsule._uuid = 'if you want it the same'
                            capsule.createdAt = Date.now() 
                            done()


            instance = Notifier.create 'title'
            instance.pheeew

                defcon:  1
                change: -4

            .then (newCapsule) -> 

                #console.log newCapsule
                newCapsule.should.eql 

                    id:        'new database record id'
                    createdAt: 'wrist watch'
                    defcon:     1
                    change:     -4

                #console.log newCapsule.sourceHost
                done()


        it 'assigns the capsule typeValue from string or number', (done) -> 

            Notifier = notifier 
                capsule: 
                    alert: {}

            instance = Notifier.create 'title'

            capsules = []

            instance.alert( 'something bad' ).then (m) -> capsules.push m
            instance.alert( 3 ).then (m) -> 
                capsules.push m
                capsules.should.eql [
                    { alert: 'something bad' }
                    { alert: 3 }
                ]
                done()


        it 'can assign additional payload after the typeValue', (done) -> 

            instance = notifier().create 'title'
            instance.event( 'event name', more: 'info' ).then (m) -> 

                m.should.eql 
                    event: 'event name'
                    more:  'info'
                done()


        it 'can assign additional payload before the typeValue', (done) -> 

            instance = notifier().create 'title'

            instance.event

                description:  '...'
                category:     '...'
                subcategory:  '...'
                'event name'

            .then (m) -> 
                m.should.eql 
                    event:       'event name'
                    description: '...'
                    category:    '...'
                    subcategory: '...'
                    
                done()

        it 'merges multiple payloads', (done) -> 

            instance = notifier().create 'title'
            payload1 = {a: 1}
            payload2 = {b: 2}
            instance.event 'name', payload1, payload2, (err, capsule) -> 

                capsule.should.eql 
                    event: 'name'
                    a: 1
                    b: 2
                done()


        it 'will not overwrite typeValue is also present in payload', (done) -> 

            instance = notifier().create 'title'
            instance.event 'event name', 
                event: 'accidental second definition of event name'
                (err, capsule) -> 
                    capsule.event.should.not.equal 'accidental second definition of event name'
                    done()


        it 'creates description with second string', (done) -> 

            instance = notifier().create 'title'
            instance.event 'string1', 'string2', (err, capsule) -> 
                capsule.should.eql
                    event: 'string1'
                    description: 'string2'
                done()


        it 'creates middleware storage and throws on duplicate title', (done) -> 

            Notifier = notifier()
            Notifier.create 'bakery'
            try Notifier.create 'bakery'
            catch π
                #console.log π
                should.exist _notifier().middleware.bakery
                π.should.match /is already defined/
                done()


        it 'provides middleware registrar', (done) -> 

            Notifier = notifier
                capsule:
                    use: 'this capsule definition is ignored'

            nine = Notifier.create 'Assembly Line 9'

            nine.use.should.be.an.instanceof Function
            done()


        it 'throws middleware registration without title and fn', (done) -> 

            seven = notifier().create 'Assembly Line 7'
            try seven.use 
                titel: 'troubled speller'
                (done, capsule) ->
            catch error
                error.should.match /requires arg opts.title and fn/
                done()


        it 'registers middleware', (done) -> 

            six = notifier().create 'Assembly Line 6'
            six.use 
                title: 'arrange into single file'
                (done, capsule) -> done()
            six.use
                title: 'squirt the product in'
                (done, capsule) -> done()
            six.use
                title: 'put a lid on it'
                (done, capsule) -> done()

            mmm = _notifier().middleware['Assembly Line 6']

            mmm['arrange into single file'] (->), {}
            mmm['squirt the product in']    (->), {}
            mmm['put a lid on it']          done, {}


        it 'creates a function to send a raw payload into the pipeline', (done) -> 

            mix = notifier().create 'Assembly Line Mix'
            #console.log mix
            mix.use 
                title: '1. intro'
                (next, capsule) -> 

                    capsule.should.equal 'VALUE'
                    done()


            mix.raw 'VALUE'


        it 'rejects the middleware traversal (promise) on throw', (done) -> 

            mix = notifier().create 'Assembly Line Mix'
            mix.use 
                title: 'one'
                (next, capsule) -> 
                    throw new Error 'reeror'


            mix.event( 'VALUE' ).then( 
                ->
                (error) -> 
                    error.message.should.equal 'reeror'
                    done()
            )



        it 'error the middleware traversal (callback) on throw', (done) -> 

            mix = notifier().create 'Assembly Line Mix'
            mix.use 
                title: 'one'
                (next, capsule) -> 
                    throw new Error 'reeror'


            mix.event 'VALUE', (error, capsule) -> 

                error.message.should.equal 'reeror'
                done()


        it 'notifies the middleware traversal (promise) on cancel', (done) -> 

            mix = notifier().create 'Assembly Line Mix'
            mix.use 
                title: 'middleware title'
                (next, capsule) -> 
                    next.cancel()


            mix.event( 'VALUE' ).then( 
                ->
                (error) -> 
                (notify) -> 

                    {_type, control, middleware, capsule} = notify
                    _type.should.equal 'control'
                    control.should.equal   'cancel'
                    middleware.should.equal 'middleware title'
                    capsule.event.should.equal 'VALUE'
                    done()
            )


        it 'passes capsule through all middleware if they call next', (done) -> 

            mix  = notifier().create 'Assembly Line Mix'

            mix.use 
                title: '1. intro'
                (done, capsule) ->
                    capsule.one = true
                    done()
            mix.use 
                title: '2. one the sun'
                (done, capsule) -> 
                    capsule.two = true
                    done()
            mix.use 
                title: '3. noon moon'
                (done, capsule) -> 
                    capsule.three = true
                    done()

            mix.event().then (m) -> 

                m.should.eql one: true, two: true, three: true
                done()

        context 'local metrics', -> 

            it 'increments input and output for each traversal', (done) -> 

                DURING = undefined
                AFTER  = undefined
                mix    = notifier().create 'Assembly Line Mix'
                mix.use title: '1. intro', (next, capsule) ->
                        
                    #
                    # mocha throws on fail
                    # middleware redirects the uncaught exception as a promise rejection
                    # so this is tricky to test
                    # 

                    DURING = JSON.parse JSON.stringify mix.serialize().metrics.local
                    next()

                mix.event().then -> 

                    AFTER = mix.serialize().metrics.local

                setTimeout (->

                    DURING.input     .should.equal 1
                    DURING.output    .should.equal 0
                    DURING.reject.usr.should.equal 0
                    DURING.reject.sys.should.equal 0

                    AFTER .input     .should.equal 1
                    AFTER .output    .should.equal 1
                    AFTER .reject.usr.should.equal 0
                    AFTER .reject.sys.should.equal 0
                    done()

                ), 100

        it 'increments usr.reject instead of output if rejected by user middleware', (done) -> 

            DURING = undefined
            AFTER  = undefined
            mix    = notifier().create 'Assembly Line Mix'
            mix.use title: '1. intro', (next, capsule) ->
                    
                #
                # mocha throws on fail
                # middleware redirects the uncaught exception as a promise rejection
                # so this is tricky to test
                # 

                DURING = JSON.parse JSON.stringify mix.serialize().metrics.local
                throw new Error

            mix.event().then (->), -> 

                AFTER = mix.serialize().metrics.local

            setTimeout (->

                DURING.input     .should.equal 1
                DURING.output    .should.equal 0
                DURING.reject.usr.should.equal 0
                DURING.reject.sys.should.equal 0

                AFTER .input     .should.equal 1
                AFTER .output    .should.equal 0
                AFTER .reject.usr.should.equal 1
                AFTER .reject.sys.should.equal 0


                done()

            ), 100

        it 'increments sys.reject instead of output if rejected by system middleware', (done) -> 

            DURING = undefined
            AFTER  = undefined
            mix    = notifier().create 'Assembly Line Mix'

            mix.use title: 'last', last: true, (next, capsule) ->

                throw new Error


            mix.use title: '1. intro', (next, capsule) ->
                
                #
                # mocha throws on fail
                # middleware redirects the uncaught exception as a promise rejection
                # so this is tricky to test
                # 

                DURING = JSON.parse JSON.stringify mix.serialize().metrics.local
                next()

            mix.event()


            setTimeout (->

                AFTER = mix.serialize().metrics.local

                DURING.input     .should.equal 1
                DURING.output    .should.equal 0
                DURING.reject.usr.should.equal 0
                DURING.reject.sys.should.equal 0

                AFTER .input     .should.equal 1
                AFTER .output    .should.equal 0
                AFTER .reject.usr.should.equal 0
                AFTER .reject.sys.should.equal 1


                done()

            ), 100

        it 'a traversal context travels the pipeline in tandem with the capsule', (done) -> 

            mix  = notifier().create 'Assembly Line Mix'
            mix.use 
                title: '1. intro'
                (next, capsule, context) ->

                    context.x = 'αω'
                    done()
            mix.use 
                title: '2. one the sun'
                (next, capsule, context) -> 

                    context.x.should.equal 'αω'
                    done()

            mix.event()


        it 'middleware can notify the promise via next.notify()', (done) -> 

            mix  = notifier().create 'Assembly Line Mix'

            mix.use 
                title: '1. intro'
                (next, capsule) ->
                    next.notify 'update'
                    capsule.one = true
                    next()

            mix.event().then( 
                (m) -> 
                (e) -> 
                (notify) -> 
                    notify.should.equal 'update'
                    done()

            )

        it 'middleware can reject the promise via next.reject()', (done) -> 

            mix = notifier().create 'Assembly Line Mix'

            mix.use 
                title: '1. intro'
                (next, capsule, context) ->
                    capsule.one = 1
                    context.one = 1
                    next()
            mix.use 
                title: '2. one the sun'
                (next, capsule, context) -> 
                    
                    next.reject new Error 'ERROR'


            mix.event (err, finalCapsule) -> 

                err.should.match /ERROR/
                done()



        it 'can use the force() to replace middleware', (done) -> 

            mix  = notifier().create 'Assembly Line Mix'
            deck = _notifier().middleware['Assembly Line Mix']

            mix.use 
                title: '1. intro'
                (done, capsule) -> done()
            mix.use 
                title: '2. one the sun'
                (done, capsule) -> done()
            mix.use 
                title: '3. noon moon'
                (done, capsule) -> done()
            mix.use
                title: '4. byte orbit'
                (done, capsule) -> done()
            
            mix.force 
                title: '1. intro', 
                (done, capsule) -> 
                    ### replaced ### 
                    done()

            deck['1. intro'].toString().should.match /replaced/
            done()

        it 'has a dark side of the force()', (done) -> 

            mix  = notifier().create 'Assembly Line Mix'
            deck = _notifier().middleware['Assembly Line Mix']

            mix.use 
                title: '1. intro'
                (done, capsule) -> done()
            mix.use 
                title: '2. one the sun'
                (done, capsule) -> done()

            mix.force
                title: '1. intro'
                delete: true

            should.not.exist deck['1. intro']
            done()


        it 'can register a last middleware', (done) -> 

            stix = notifier().create 'Happy Ending'

            stix.use 
                title: 'three'
                last:   true
                (done, capsule) -> 
                    capsule.array.push 'three'
                    done()

            stix.use 
                title: 'one'
                (done, capsule) -> 
                    capsule.array = []
                    capsule.array.push 'one'
                    done()
            stix.use 
                title: 'two'
                (done, capsule) -> 
                    capsule.array.push 'two'
                    done()

            stix.event (err, res) -> 

                #console.log res
                res.array.should.eql ['one', 'two', 'three']
                done()



        it 'can only register a last middleware once', (done) -> 

            stix = notifier().create 'Happy Ending'

            stix.use 
                title: 'three'
                last:   true
                (done, capsule) -> 
                    capsule.array.push 'three'
                    done()

            stix.use 
                title: 'one'
                (done, capsule) -> 
                    capsule.array = []
                    capsule.array.push 'one'
                    done()
            stix.use 
                title: 'two'
                (done, capsule) -> 
                    capsule.array.push 'two'
                    done()

            swap = process.stderr.write # sssht, once
            process.stderr.write = -> process.stderr.write = swap

            stix.use 
                title: 'three'
                last:   true
                (done, capsule) -> 
                    capsule.array.push 'replace three'
                    done()

            stix.event (err, res) -> 

                #console.log res
                res.array.should.eql ['one', 'two', 'three']
                done()

        it 'can register a first middleware', (done) -> 

            stix = notifier().create 'Happy Beginning'
            stix.use 
                title: 'one'
                (done, capsule) -> 
                    capsule.array ||= []
                    capsule.array.push 'one'
                    done()
            stix.use 
                title: 'two'
                first:          true
                (done, capsule) -> 
                    capsule.array ||= []
                    capsule.array.push 'zero'
                    done()

             stix.event (err, res) -> 
                res.array.should.eql [ 'zero', 'one' ]
                done()
                

        it 'sequence is preserved when replacing middleware', (done) -> 

            {sequence, deferred} = require 'also'
            five = notifier().create 'Assembly Line 5'
            five.use 
                title: 'one'
                (done, capsule) -> 
                    capsule.array = [1]
                    done()
            five.use 
                title: 'REPLACE ME'
                (done, capsule) -> 
                    capsule.array.push 2
                    done()
            five.use 
                title: 'three'
                (done, capsule) -> 
                    capsule.array.push 3
                    done()
            five.force 
                title: 'REPLACE ME'
                (done, capsule) -> 
                    capsule.array.push 'new 2'
                    done()

            five.event().then (capsule) -> 

                capsule.array.should.eql  [ 1, 'new 2', 3 ]
                done()

        it 'returns the promise of a capsule traversing the middleware pipeline', (done) -> 

            Notifier = notifier 
                capsule:
                    makeThing: 
                        before: (done, capsule) ->
                            capsule.serialNo = '0000000000001'
                            done()

            four = Notifier.create 'Assembly Line 4'
            four.use title: 'step1', (done, capsule) -> 
                capsule.step1 = 'done'
                done()
            four.use title: 'step2', (done, capsule) ->
                capsule.step2 = 'done'
                done()

            four.makeThing

                colour: 'red'

            .then (result) -> 

                result.should.eql

                    serialNo: '0000000000001'
                    colour: 'red'
                    step1: 'done'
                    step2: 'done'

                done()


        it 'rejects on failing middleware', (done) -> 

            Notifier = notifier capsule: info: {}
            broken = Notifier.create 'broken pipeline'
            broken.use title: 'fails', (done, capsule) -> 
                throw new Error 'ka-pow!'
                done()

            broken.info().then (->), (error) ->

                error.message.should.equal 'ka-pow!'
                done()


        it 'also accepts traditional node style callback to receive the error or final capsule', (done) -> 

            Notifier = notifier()
            instance = Notifier.create 'title'

            instance.use title: 'title', (done, capsule) -> 
                capsule.ok = 'good'
                done()


            instance.event payload: 'ABCDEFG', (err, capsule) -> 

                capsule.should.eql
                     payload: 'ABCDEFG'
                     ok:      'good'
                done()



        it 'has mech for first and last middlewares for hub and client'


