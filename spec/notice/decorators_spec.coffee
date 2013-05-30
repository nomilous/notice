require('nez').realize 'Decorators', (Decorators, test, context) -> 


    context 'onceIfString( fn )', (it) -> 

        it 'ensures the fn is only run once, and only if a string is passed', (done) -> 

            VALUES = []

            fn = Decorators.onceIfString (value) -> VALUES.push value
            fn 4
            fn []
            fn {}
            fn true
            VALUES.length.should.equal 0
            fn 'runs with this'
            fn 'but not again'
            VALUES.should.eql [ 'runs with this' ]
            test done


    context 'isFn( fn )', (it) -> 

        it 'ensures the provided arg is a Function', (done) -> 

            runCount = 0

            f = Decorators.isFn (value) -> runCount++ && value()
            f {}
            f ''
            f []
            f 0
            runCount.should.equal 0
            f (x) -> 1 / y
            runCount.should.equal 1
            test done

    context 'isMiddleware', (it) -> 

        it 'ensures the provided arg is a middleware function', (done) -> 

            middleware = []
            app = use: Decorators.isMiddleware (fn) -> middleware.push fn

            app.use () -> 
            middleware.length.should.equal 0

            app.use (msg, next) -> 
            middleware.length.should.equal 0

            app.use (arg1, arg2) -> arg2()
            middleware.length.should.equal 1



            test done
