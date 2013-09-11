#require('nez').realize 'Message', (Message, test, context, should) -> 
    
Message = require '../../lib/notice/message'
should  = require 'should'

describe 'Message', -> 

    context 'title and description', -> 

        it 'can be defined on construction', (done) -> 

            m = new Message title: 'TITLE', description: 'DESCRIPTION'
            m.title.should.equal 'TITLE'
            m.description.should.equal 'DESCRIPTION'
            done()

        it 'can be set, but only once', (done) -> 

            m             = new Message
            m.title       = 'TITLE ONE'
            m.title       = 'TITLE TWO'
            m.description = 'DESCRIPTION ONE'
            m.description = 'DESCRIPTION TWO'

            m.title.should.equal 'TITLE ONE'
            m.description.should.equal 'DESCRIPTION ONE'
            done()

        it 'will only be set with strings', (done) -> 

            m             = new Message
            m.title       = ['TITLE ONE']
            m.description = ['DESCRIPTION ONE']

            m.title.should.equal ''
            m.description.should.equal ''
            done()


    context 'event', -> 

        it 'is the title if type is event', (done) -> 

            m = new Message title: 'TITLE', description: 'DESCRIPTION'
            should.not.exist m.event 

            e = new Message title: 'TITLE', description: 'DESCRIPTION', type: 'event'
            e.event.should.equal 'TITLE'
            done()


    context 'info', -> 

        it 'is the title if type is info', (done) -> 

            m = new Message title: 'TITLE', description: 'DESCRIPTION'
            should.not.exist m.info 

            e = new Message title: 'TITLE', description: 'DESCRIPTION', type: 'info'
            e.info.should.equal 'TITLE'
            done()


    context 'content', -> 

        it 'returns message context', (done) ->

            m             = new Message
            m.title       = 'TITLE ONE'
            m.description = 'DESCRIPTION ONE'
            m.origin      = 'ORIGIN'
            m.type        = 'TYPE'
            m.tenor       = 'TENOR'
            m.direction   = 'DIRECTION'

            m.context.should.eql 
                title:       'TITLE ONE'
                description: 'DESCRIPTION ONE'
                origin:      'ORIGIN'
                type:        'TYPE'
                tenor:       'TENOR'
                direction:   'DIRECTION'


            done()
