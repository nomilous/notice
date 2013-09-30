#require('nez').realize 'Decorators', (Decorators, test, context, should) -> 


Decorators = require '../../lib/notice/decorators'
should     = require 'should'

describe 'Decorators', ->

    # context 'onceIfString( fn )',-> 

    #     it 'ensures the fn is only run once, and only if a string is passed', (done) -> 

    #         VALUES = []

    #         fn = Decorators.onceIfString (value) -> VALUES.push value
    #         fn 4
    #         fn []
    #         fn {}
    #         fn true
    #         VALUES.length.should.equal 0
    #         fn 'runs with this'
    #         fn 'but not again'
    #         VALUES.should.eql [ 'runs with this' ]
    #         done()


    # context 'isFn( fn )',-> 

    #     it 'ensures the provided arg is a Function', (done) -> 

    #         runCount = 0

    #         f = Decorators.isFn (value) -> runCount++ && value()
    #         f {}
    #         f ''
    #         f []
    #         f 0
    #         runCount.should.equal 0
    #         f (x) -> 1 / y
    #         runCount.should.equal 1
    #         done()

    # context 'isMiddleware',-> 

    #     it 'ensures the provided arg is a middleware function', (done) -> 

    #         isMiddleware = Decorators.isMiddleware
    #         middleware   = []

    #         app = use: isMiddleware (fn) -> middleware.push fn

    #         app.use () -> 
    #         middleware.length.should.equal 0

    #         app.use (msg, next) -> 
    #         middleware.length.should.equal 0

    #         app.use (arg1, arg2) -> arg2()
    #         middleware.length.should.equal 1

    #         done()


    # context 'asResolver', -> 

    #     it 'wraps the provided function into a deferral and 
    #         calls with the resolver as middleware `nextFn`', (done) -> 

    #         asResolver = Decorators.asResolver
    #         middleware = []

    #         app = use: asResolver (fn) -> middleware.push fn

    #         app.use (msg, next) -> 

    #             msg.addsThis = 'IN the MIDDLE ware'
    #             next msg

    #         middleware[0]( startsWith: 'THIS' ).then (result) -> 

    #             result.should.eql

    #                 startsWith: 'THIS'
    #                 addsThis: 'IN the MIDDLE ware'
                
    #             done()

    # context 'supports isMiddleWare and asResolver',-> 

    #     it 'conjunction', (done) -> 

    #         asResolver   = Decorators.asResolver
    #         isMiddleware = Decorators.isMiddleware

    #         middleware = undefined
    #         use = isMiddleware asResolver (m) -> middleware = m

    #         use (msg, next) ->
    #             msg.should.eql is: 'something'
    #             next() 
    #             done()

    #         middleware( is: 'something' )


    context 'asUniq( fn )', -> 

        it 'injects a unique id', (done) -> 

            asUniq = Decorators.asUniq

            class Test
                constructor: asUniq (@id, @arg) -> 

            test1 = new Test 'ARG'
            test2 = new Test 'ARG'

            should.exist test1.id
            test1.id.should.not.equal test2.id
            done()


