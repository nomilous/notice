{middleware,_middleware} = require '../../lib/management/middleware'
should = require 'should'

describe 'middleware', -> 

    it 'is a middleware collection', -> 

    it 'defines update', -> 

        middleware().update.should.be.an.instanceof Function

    it 'assigns next slot if not specified', (done) -> 

        instance = middleware()
        _middleware().nextSlot = -> done(); 1
        instance.update {}
