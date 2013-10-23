{middleware,_middleware} = require '../../lib/management/middleware'
should = require 'should'

describe 'middleware', -> 

    beforeEach ->

        @middleware = 

            slot: 1
            title: 'Title'
            description: 'Description'
            enabled: true
            fn: ->


    it 'is a middleware collection', -> 

        instance = middleware()
        #console.log _middleware()


    it 'defines update to update middleware', -> 

        middleware().update.should.be.an.instanceof Function


    it 'assigns next slot if not specified', (done) -> 

        instance = middleware()
        _middleware().nextSlot = -> done(); 1
        delete @middleware.slot
        instance.update @middleware


    it 'inserts middleware into slots', (done) -> 

        instance = middleware()
        instance.update @middleware

        _middleware().slots[1].slot.should.equal 1
        _middleware().slots[1].title.should.equal 'Title'
        _middleware().slots[1].description.should.equal 'Description'
        _middleware().slots[1].type.should.equal 'usr'
        _middleware().slots[1].enabled.should.equal true

        done()


    it 'refreshes bottomSlot on auto assign slot', (done) -> 

        instance = middleware()
        _middleware().bottomSlot = 100
        delete @middleware.slot
        instance.update @middleware
        _middleware().bottomSlot.should.equal 101
        done()


    it 'refreshes bottomSlot on specified slot', (done) -> 

        instance = middleware()
        _middleware().bottomSlot = 50
        @middleware.slot = 100
        instance.update @middleware
        _middleware().bottomSlot.should.equal 101
        done()


    it 'reloads after update', (done) -> 

        instance = middleware()
        _middleware().reload = done
        instance.update @middleware


    context 'reload', -> 

        it 'switches between active array', ->

            instance = middleware()
            _middleware().active.should.equal 'array1'
            instance.update @middleware
            _middleware().active.should.equal 'array2'


        it 'loads middlewares sorted by slot into the next active array', (done) ->

            instance = middleware()
            slots = _middleware().slots

            slots[5]  = { enabled: true, title: 'FIVE'     }
            slots[1]  = { enabled: true, title: 'ONE'      }
            slots[99] = { enabled: true, title: 'NINENINE' }

            _middleware().running().should.eql []
            _middleware().active.should.equal 'array1'
            _middleware().reload()
            _middleware().active.should.equal 'array2'
            _middleware().running()[1..3].should.eql [

                { enabled: true, title: 'ONE'        }
                { enabled: true, title: 'FIVE'       }
                { enabled: true, title: 'NINENINE'   }

            ]

            done()


        it 'skips middleware that is not enabled', (done) ->

            instance = middleware()
            slots = _middleware().slots

            slots[5]  = { enabled: false, title: 'FIVE'     }
            slots[1]  = { enabled: true,  title: 'ONE'      }
            slots[99] = { enabled: true,  title: 'NINENINE' }

            _middleware().reload()
            _middleware().running()[1..2].should.eql [

                { enabled: true, title: 'ONE'      }
                # { enabled: true, title: 'FIVE'     }
                { enabled: true, title: 'NINENINE' }
            ]

            done()


    context 'running()', -> 

        it 'returns the active array', -> 

            instance = middleware()
            _middleware().active = 'array2'
            instance.running().should.equal _middleware().array2

    
    context 'sys middleware', (done) -> 

        it 'can replace first middleware only once', (done) -> 

            instance = middleware()
            instance.first -> 'one'
            instance.first -> 'two'

            #console.log _middleware().running()[0]
            _middleware().running()[0].fn().should.equal 'one'
            done()

        it 'can replace first middleware only once', (done) -> 

            instance = middleware()
            instance.last -> 'one'
            instance.last -> 'two'

            #console.log _middleware().running()[0]
            _middleware().running()[1].fn().should.equal 'one'
            done()




        
