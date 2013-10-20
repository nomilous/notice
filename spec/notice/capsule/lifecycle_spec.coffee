should      = require 'should'
{lifecycle} = require '../../../lib/notice/capsule/lifecycle'
{_Capsule}  = require '../../../lib/notice/capsule/capsule'

describe 'lifecycle', -> 

    it 'maintains a capsule cache', (done) -> 

        ls = lifecycle 'event', {}
        should.exist ls.cache
        done()


    context 'create', -> 

        it 'creates a capsule asynchronously', (done) -> 

            #
            # To enable DB/www to play a primary role in creation  
            # 

            ls = lifecycle 'event', {}
            ls.create().then (capsule) -> 
                capsule.should.be.an.instanceof _Capsule()
                done()


        it 'first calls the capsule specific before hook', (done) -> 

            SEQUENCE = []
            ls = lifecycle 'event', 
                capsule: 
                    event: 
                        before: (done) -> 
                            SEQUENCE.push 'before hook'
                            done()

            ls.create().then (capsule) -> 

                SEQUENCE.push 'resolved'
                SEQUENCE.should.eql ['before hook', 'resolved']
                done()



        it 'protects from hooks that never resolve' # how long is a piece of string's timeout
        it 'passes a resolver to the hook and pends the creation resolution thru it', (done) -> 

            DONE    = undefined
            CAPSULE = undefined
            ls = lifecycle 'event', 
                capsule: 
                    event: 
                        before: (done) -> DONE = done
            ls.create().then (capsule) -> CAPSULE = capsule

            should.not.exist CAPSULE
            DONE()
            # process.nextTick -> # dunno why not?
            setTimeout (->

                should.exist CAPSULE
                done()

            ), 30


        it 'passes the capsule to the hook', (done) ->

            ls = lifecycle 'event', 
                capsule: 
                    event: 
                        before: (done, capsule) -> 

                            setTimeout (->
                                capsule.did = 'an async thing'
                                done()
                            ), 30

            ls.create().then (capsule) -> 
                capsule.did.should.equal 'an async thing'
                done()


        it 'assigns capsule type before before', (done) -> 

            ls = lifecycle 'event', 
                capsule: 
                    event: 
                        before: (dun, capsule) -> 
                            capsule.$$type.should.equal 'event'
                            done()

            ls.create()


        it 'assigns capsule properties before the hook', (done) -> 

            ls = lifecycle 'event', 
                capsule: 
                    event: 
                        before: (dun, capsule) -> 
                            capsule.should.eql key: 'value'
                            dun()
                            done()


            ls.create key: 'value'


        it 'protects the typeValue', (done) -> 

            ls = lifecycle 'event', 
                capsule: 
                    event: 
                        before: (done, capsule) -> 
                            
                            capsule.event = 'cannot be renamed'
                            capsule.evenTho = 'i tried to change it'
                            done()

            ls.create( event: 'is still this' ).then (capsule) -> 
                capsule.should.eql
                    event:    'is still this'
                    evenTho: 'i tried to change it'

                done()

        it 'does not assign a uuid if the hook did', (done) -> 

            ls = lifecycle 'event', 
                capsule: 
                    event: before: (done, capsule) -> 
                        capsule._uuid = 1
                        done()

            ls.create().then (capsule) -> 
                capsule._uuid.should.equal 1
                done()

        it 'does not assign uuid if the emitter did', (done) -> 

            ls = lifecycle 'event', 
                capsule: 
                    event: {}

            ls.create( _uuid: 1 ).then (capsule) -> 
                capsule._uuid.should.equal 1
                done()


        it 'assigns uuid if the hook didnt', (done) -> 

            ls = lifecycle 'event', 
                capsule: 
                    event: before: (done, capsule) -> done()

            ls.create().then (capsule) -> 

                should.exist capsule._uuid
                done()

        it 'assigns uuid if there is no hook', (done) -> 

            ls = lifecycle 'event', 
                capsule: 
                    event: {}

            ls.create().then (capsule) -> 

                should.exist capsule._uuid
                done()



        it 'rejects on error in hook', (done) -> 

            π = new Error
            ls = lifecycle 'event', 
                capsule: 
                    event: before: (done, capsule) -> throw π

            ls.create().then(
                ->
                (error) -> 
                    error.should.equal π
                    done()
            )



