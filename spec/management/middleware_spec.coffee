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


    it 'defines update', -> 

        middleware().update.should.be.an.instanceof Function


    it 'assigns next slot if not specified', (done) -> 

        instance = middleware()
        _middleware().nextSlot = -> done(); 1
        delete @middleware.slot
        instance.update @middleware


    it 'inserts middleware into slots', (done) -> 

        instance = middleware()
        instance.update @middleware
        _middleware().slots[1].should.equal @middleware
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

        



