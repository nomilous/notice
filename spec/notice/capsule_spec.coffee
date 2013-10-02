{capsule, _capsule} = require '../../lib/notice/capsule'
should    = require 'should'

describe 'Capsule', -> 

    context 'set()', -> 

        it 'sets a property', (done) -> 

            Capsule = capsule()
            instance = new Capsule
            instance.set property: 'value'

            instance.property.should.equal 'value'
            done()