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

        context 'protected', -> 

            it 'sets a property to readonly', (done) -> 

                Capsule = capsule()
                instance = new Capsule
                instance.set 
                    protected: true
                    property: 'original'

                instance.property = 'changed'
                instance.property.should.equal 'original'
                done()


            it 'does not allow reset of protected', (done) -> 

                Capsule = capsule()
                instance = new Capsule

                instance.set 
                    protected: true
                    property: 'original'

                instance.set 
                    protected: false
                    property: 'changed'

                #
                # nice! writable can only be set to 'no' once
                #

                instance.should.eql property: 'original'
                done()


        context 'hidden', ->  

            it 'sets a property to invisible', (done) -> 

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

        it 'can do hidden and protected', (done) -> 

            Capsule = capsule()
            instance = new Capsule
            instance.set 
                hidden: true
                protected: true
                property: 'original'

            instance.should.eql {}
            instance.property.should.equal 'original'
            instance.property = 'changed'
            instance.property.should.equal 'original'
            done()


        context 'watched()', -> 

            it 'sets a property to watched', (done) -> 

                CHANGES = {}
                Capsule = capsule()
                instance = new Capsule
                instance.set
                    watched: (property, change, obj) -> 
                        CHANGES[property] ||= []
                        CHANGES[property].push change
                    thing: 'one'

                instance.thing = 'two'
                instance.thing = 'three'
                instance.thing = 'four'

                CHANGES.should.eql 
                    thing: [
                        { from: undefined, to: 'one'   }
                        { from: 'one'    , to: 'two'   }
                        { from: 'two'    , to: 'three' }
                        { from: 'three'  , to: 'four'  }
                    ]
                done()


