{capsule, _capsule} = require '../../../lib/notice/capsule/capsule'
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
                    property: 'original'
                    protected: true
                    

                instance.property = 'changed'
                instance.property.should.equal 'original'
                done()


            it 'does not allow reset of protected', (done) -> 

                Capsule = capsule()
                instance = new Capsule

                instance.set 
                    property: 'original'
                    protected: true
                    

                instance.set 
                    property: 'changed'
                    protected: false
                    

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
                    property: 'value'
                    hidden: true
                    
                instance.should.eql {}
                instance.property.should.equal 'value'
                done()


            it 'allows reset of hidden', (done) -> 

                Capsule = capsule()
                instance = new Capsule
                
                instance.set 
                    property: 'value'
                    hidden: true
                    

                instance.should.eql {}

                instance.set 
                    property: 'value'
                    hidden: false
                    

                instance.should.eql property: 'value'
                done()

        it 'can do hidden and protected', (done) -> 

            Capsule = capsule()
            instance = new Capsule
            instance.set 
                property: 'original'
                hidden: true
                protected: true
                

            instance.should.eql {}
            instance.property.should.equal 'original'
            instance.property = 'changed'
            instance.property.should.equal 'original'
            done()


        context 'watched()', -> 

            it 'sets a property to watched', (done) -> 

                CHANGES = []
                Capsule = capsule()
                instance = new Capsule
                instance.set
                    thing: 'one'
                    watched: (change) -> 
                        CHANGES.push change
                    
                instance.anotherProperty = 1
                instance.thing = 'two'
                instance.anotherProperty = 2

                CHANGES.should.eql [
                    { property: 'thing', from: undefined, to: 'one', capsule: { thing: 'two', anotherProperty: 2 } }
                    { property: 'thing', from: 'one',     to: 'two', capsule: { thing: 'two', anotherProperty: 2 } }
                ]
                done()

            it 'warns on attempt to watch protected property', (done) -> 

                swap = process.stderr.write
                process.stderr.write = (err) -> 
                    process.stderr.write = swap
                    err.should.equal 'cannot watch protected property:thing'
                    done()

                Capsule = capsule()
                instance = new Capsule
                instance.set
                    thing: 'one'
                    protected: true
                    watched: (property, change, obj) -> 
                    












