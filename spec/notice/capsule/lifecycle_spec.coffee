should      = require 'should'
{lifecycle} = require '../../../lib/notice/capsule/lifecycle'

describe 'lifecycle', -> 

    it 'maintains a capsule cache', (done) -> 


        ls = lifecycle 'event', {}
        should.exist ls.cache
        done()

