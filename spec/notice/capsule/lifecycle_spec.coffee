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



        it 'protects from hooks that never resolve'
        it 'passes a resolver that pends the creation', (done) -> 

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

