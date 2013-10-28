{_notifier, notifier} = require '../../lib/notice/notifier'
{sequence} = require 'also'
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
            instance.$control.should.be.an.instanceof Function
            done()

        it 'creates a builtin tick capsule emitter', (done) -> 

            Notifier = notifier()
            instance = Notifier.create 'title', 'uuid'
            instance.$tick.should.be.an.instanceof Function
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
                            # or capsule.$uuid = 'if you want it the same'
                            capsule.createdAt = Date.now() 
                            done()


            instance = Notifier.create 'title'

            # console.log instance
            instance.pheeew

                defcon:  1
                change: -4

            .then( 
                (newCapsule) -> 
                    #console.log newCapsule
                    newCapsule.should.eql 

                        id:        'new database record id'
                        createdAt: 'wrist watch'
                        defcon:     1
                        change:     -4

                    #console.log newCapsule.sourceHost
                    done()

                (error) -> 

                    console.log SPEC_ERROR_1: error
                    done()
            )


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
                description: """
                Note. If it starts vibrating something crazy it means there's
                      some that are wedged in the funnel track.

                      Please unwedge as a matter of extreem urgency!
                      A boat-hook has been provived.
                """
                (next, capsule) -> next()

            six.use
                title: 'squirt the product in'
                (next, capsule) -> next()
            six.use
                title: 'put a lid on it'
                (next, capsule) -> next()

            mwareFn = _notifier().middleware['Assembly Line 6'].running()[1]
            mwareFn.title.should.equal 'arrange into single file'
            done()


        it 'creates a function to send a raw payload into the pipeline', (done) -> 

            mix = notifier().create 'Assembly Line Mix'
            #console.log mix
            mix.use 
                title: '1. intro'
                (next, capsule) -> 

                    capsule.should.equal 'VALUE'
                    done()


            mix.$raw 'VALUE'

        #DUPLICATE
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

        it 'suspends further traversal of the pipeline on cancel', (done) -> 

            mix = notifier().create 'Assembly Line Mix'
            mix.use title: 'one'  , (next, capsule) -> capsule.one   = true; next()
            mix.use title: 'two'  , (next, capsule) -> capsule.two   = true; next()
            mix.use title: 'three', (next, capsule) -> capsule.three = true; next()
            mix.use title: 'four' , (next, capsule) -> next.cancel()
            mix.use title: 'five' , (next, capsule) -> 
                console.log SHOULD_NOT_SEE_THIS: capsule
                capsule.five  = true; next()


            CANCELLED = undefined
            mix.event( 'VALUE' ).then( 
                (capsule) -> console.log capsule
                (error)   -> console.log error
                (notify)  -> CANCELLED = notify.capsule if notify.control == 'cancel'    
            )


            setTimeout (->
                CANCELLED.should.eql 
                    event: 'VALUE'
                    one: true
                    two: true
                    three: true
                
                done()
            ), 100


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

            mix.event (e, m) ->

                m.should.eql one: true, two: true, three: true
                done()


        it 'provides notifier cache into middleware as traversal.cache', (done) -> 

            mix = notifier().create 'Assembly Line Mix'
            mix.cache = value: 'hotswapped middleware have no surrounding scope...'
            mix.use 
                title: 'one'
                (next, capsule, traversal) -> 
                    capsule.set = traversal.cache.value
                    next()

            mix.event (err, capsule) -> 

                capsule.set.should.equal 'hotswapped middleware have no surrounding scope...'
                done()

        it 'provides notifier tools into middleware as traversal.tools', (done) -> 

            mix = notifier().create 'Assembly Line Mix'
            mix.tools = value: 'hotswapped middleware have no surrounding scope...'
            mix.use 
                title: 'one'
                (next, capsule, traversal) -> 
                    capsule.value = traversal.tools.value
                    next()

            mix.event (err, capsule) -> 
                capsule.value.should.equal 'hotswapped middleware have no surrounding scope...'
                done()


        context 'serialize', -> 

            it 'at detail 1', (done) -> 

                mix       = notifier().create 'Assembly Line Mix', 1
                result    = mix.serialize(1)

                result.should.eql
                    title: 'Assembly Line Mix'
                    uuid: 1,
                    stats: 
                        pipeline: 
                            input: 
                                count: 0
                            processing: 
                                count: 0
                            output:
                                count: 0
                            error: 
                                term:
                                    usr: 0
                                    sys: 0
                                pass:
                                    usr: 0
                                    sys: 0
                            cancel: 
                                usr: 0
                                sys: 0
                    done()

            it 'at detail 2', (done) -> 

                mix    = notifier().create 'Assembly Line Mix', 1
                mix.cache = this: 'cache is also accessable via api'
                
                mix.use 
                    title: 'Title'
                    (next) -> next()

                mix.use
                    slot: 7
                    title: 'Title'
                    (next) -> next()
                
                result = mix.serialize(2)
                result.errors.should.eql recent: []
                should.exist result.middlewares[1]
                should.not.exist result.middlewares[6]
                should.exist result.middlewares[7]
                result.cache.should.eql this: 'cache is also accessable via api'
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

                    DURING = JSON.parse JSON.stringify mix.serialize().stats.pipeline
                    next()

                mix.event().then -> 

                    AFTER = mix.serialize().stats.pipeline

                setTimeout (->

                    DURING.input.count.should.equal 1
                    DURING.processing.count.should.equal 1
                    DURING.output.count.should.equal 0
                    DURING.error.term.usr.should.equal 0
                    DURING.error.term.sys.should.equal 0
                    DURING.cancel.usr.should.equal 0
                    DURING.cancel.sys.should.equal 0

                    AFTER.input.count.should.equal 1
                    AFTER.processing.count.should.equal 0
                    AFTER.output.count.should.equal 1
                    AFTER.error.term.usr.should.equal 0
                    AFTER.error.term.sys.should.equal 0
                    AFTER.cancel.usr.should.equal 0
                    AFTER.cancel.sys.should.equal 0

                    done()

                ), 100

        it 'increments usr.error instead of output if rejected by user middleware', (done) -> 

            DURING = undefined
            AFTER  = undefined
            mix    = notifier().create 'Assembly Line Mix'
            mix.use title: '1. intro', (next, capsule) ->
                    
                #
                # mocha throws on fail
                # middleware redirects the uncaught exception as a promise rejection
                # so this is tricky to test
                # 

                DURING = JSON.parse JSON.stringify mix.serialize().stats.pipeline
                throw new Error

            mix.event().then (->), -> 

                AFTER = mix.serialize().stats.pipeline

            setTimeout (->

                DURING.input.count.should.equal 1
                DURING.processing.count.should.equal 1
                DURING.output.count.should.equal 0
                DURING.error.term.usr.should.equal 0
                DURING.error.term.sys.should.equal 0
                DURING.cancel.usr.should.equal 0
                DURING.cancel.sys.should.equal 0

                AFTER.input.count.should.equal 1
                AFTER.processing.count.should.equal 0
                AFTER.output.count.should.equal 0
                AFTER.error.term.usr.should.equal 1
                AFTER.error.term.sys.should.equal 0
                AFTER.cancel.usr.should.equal 0
                AFTER.cancel.sys.should.equal 0

                done()

            ), 100

        it 'increments sys.error instead of output if rejected by system middleware', (done) -> 

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

                DURING = JSON.parse JSON.stringify mix.serialize().stats.pipeline
                next()

            mix.event()


            setTimeout (->

                AFTER = mix.serialize().stats.pipeline

                DURING.input.count.should.equal 1
                DURING.processing.count.should.equal 1
                DURING.output.count.should.equal 0
                DURING.error.term.usr.should.equal 0
                DURING.error.term.sys.should.equal 0
                DURING.cancel.usr.should.equal 0
                DURING.cancel.sys.should.equal 0

                AFTER.input.count.should.equal 1
                AFTER.processing.count.should.equal 0
                AFTER.output.count.should.equal 0
                AFTER.error.term.usr.should.equal 0
                AFTER.error.term.sys.should.equal 1
                AFTER.cancel.usr.should.equal 0
                AFTER.cancel.sys.should.equal 0

                done()

            ), 100


        it 'increments sys.cancel instead of output if cancelled by system middleware', (done) -> 

            DURING = undefined
            AFTER  = undefined
            mix    = notifier().create 'Assembly Line Mix'

            mix.use title: 'last', last: true, (next, capsule) ->

                DURING = JSON.parse JSON.stringify mix.serialize().stats.pipeline
                next.cancel()


            mix.use title: '1. intro', (next, capsule) ->
                
                next()

            mix.event()


            setTimeout (->

                AFTER = mix.serialize().stats.pipeline

                DURING.input.count.should.equal 1
                DURING.processing.count.should.equal 1
                DURING.output.count.should.equal 0
                DURING.error.term.usr.should.equal 0
                DURING.error.term.sys.should.equal 0
                DURING.cancel.usr.should.equal 0
                DURING.cancel.sys.should.equal 0

                AFTER.input.count.should.equal 1
                AFTER.processing.count.should.equal 0
                AFTER.output.count.should.equal 0
                AFTER.error.term.usr.should.equal 0
                AFTER.error.term.sys.should.equal 0
                AFTER.cancel.usr.should.equal 0
                AFTER.cancel.sys.should.equal 1

                done()

            ), 100


        it 'increments usr.cancel instead of output if cancelled by user middleware', (done) -> 

            DURING = undefined
            AFTER  = undefined
            mix    = notifier().create 'Assembly Line Mix'

            mix.use title: 'last', last: true, (next, capsule) ->

                next()


            mix.use title: '1. intro', (next, capsule) ->
                
                DURING = JSON.parse JSON.stringify mix.serialize().stats.pipeline
                next.cancel()

            mix.event()


            setTimeout (->

                AFTER = mix.serialize().stats.pipeline

                DURING.input.count.should.equal 1
                DURING.processing.count.should.equal 1
                DURING.output.count.should.equal 0
                DURING.error.term.usr.should.equal 0
                DURING.error.term.sys.should.equal 0
                DURING.cancel.usr.should.equal 0
                DURING.cancel.sys.should.equal 0

                AFTER.input.count.should.equal 1
                AFTER.processing.count.should.equal 0
                AFTER.output.count.should.equal 0
                AFTER.error.term.usr.should.equal 0
                AFTER.error.term.sys.should.equal 0
                AFTER.cancel.usr.should.equal 1
                AFTER.cancel.sys.should.equal 0

                done()

            ), 100

        it 'keeps a recent error history', (done) -> 

            seq = 0 
            mix = notifier().create 'Assembly Line Mix'
            mix.use title: 'middleware title', (next, capsule) -> 

                throw new Error 'message ' + ++seq
                #next()


            mix.event() for i in [0..19]
            setTimeout (->
        
                recent = mix.serialize(2).errors.recent
                recent[0].middleware.should.eql
                    title: 'middleware title'
                    type:  'usr'

                recent[0].error.should.equal 'Error: message 11'
                recent[9].error.should.equal 'Error: message 20'  # keeps 10 by default
                should.exist recent[9].timestamp

                done()

            ), 20



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

