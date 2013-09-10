# require('nez').realize 'Support', (Support, test, context) -> 

Support = require '../../lib/notice/support'
should  = require 'should'

describe 'Support', ->

    context 'argsOf', ->

        it 'returns array of a functions arg names', (done) ->

            args = Support.argsOf () -> 
            args.should.eql []

            args = Support.argsOf (arg1, arg2, arg3) -> 
            args.should.eql ['arg1', 'arg2', 'arg3']
            done()

    context 'callsArg', -> 

        it 'returns true if fn is called', (done) -> 

            Support.callsFn( 'fn', -> fn() ).should.equal true
            Support.callsFn( 'fn', -> noFn() ).should.equal false
            done()
