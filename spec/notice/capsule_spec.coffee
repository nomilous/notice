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

        it 'can set a protected property', (done) -> 

            Capsule = capsule()
            instance = new Capsule
            instance.set 
                protected: true
                property: 'original'

            instance.property = 'changed'
            instance.property.should.equal 'original'
            done()

        it 'can set a hidden property', (done) -> 

            Capsule = capsule()
            instance = new Capsule
            instance.set 
                hidden: true
                property: 'value'

            instance.should.eql {}
            instance.property.should.equal 'value'
            done()


        it 'allows reset of hidden', (done) -> 

            Capsule = capsule()
            instance = new Capsule
            
            instance.set 
                hidden: true
                property: 'value'
                
            instance.should.eql {}

            instance.set 
                hidden: false
                property: 'value'

            instance.should.eql property: 'value'
            done()
