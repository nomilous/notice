require('nez').realize 'Message', (Message, test, context, should) -> 
    

    context 'label and description', (it) -> 

        it 'can be defined on construction', (done) -> 

            m = new Message label: 'LABEL', description: 'DESCRIPTION'
            m.label.should.equal 'LABEL'
            m.description.should.equal 'DESCRIPTION'
            test done 

        it 'can be set, but only once', (done) -> 

            m             = new Message
            m.label       = 'LABEL ONE'
            m.label       = 'LABEL TWO'
            m.description = 'DESCRIPTION ONE'
            m.description = 'DESCRIPTION TWO'

            m.label.should.equal 'LABEL ONE'
            m.description.should.equal 'DESCRIPTION ONE'
            test done

        it 'will only be set with strings', (done) -> 

            m             = new Message
            m.label       = ['LABEL ONE']
            m.description = ['DESCRIPTION ONE']

            m.label.should.equal ''
            m.description.should.equal ''
            test done

    context 'content', (it) -> 

        it 'returns message context', (done) ->

            m             = new Message
            m.label       = 'LABEL ONE'
            m.description = 'DESCRIPTION ONE'

            m.context.should.eql 
                label: 'LABEL ONE'
                description: 'DESCRIPTION ONE'

            test done

