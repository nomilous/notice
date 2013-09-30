#require('nez').realize 'Message', (Message, test, context, should) -> 
    
{_message, message} = require '../../lib/notice/message'
should  = require 'should'

describe 'Message', -> 

    context 'async create()', ->

        it 'is created with a set of properties', (done) -> 

            Message = message()

            Message.create
                property1: 'value1'
                property2: 'value2'

            .then (m) -> m.should.eql
                property1: 'value1'
                property2: 'value2'
                done()


        it 'can have predefined properties', (done) -> 

            Message = message 
                properties:
                    property3: 
                        default: 'defaultValue'

            Message.create 
                property1: 'value1'

            .then (m) -> m.should.eql
                property3: 'defaultValue'
                property1: 'value1'
                done()


        it 'predefined default values are overridden', (done) ->

            Message = message 
                properties:
                    prop: 
                        default: 1

            Message.create 
                prop: 2
            .then (m) -> 
                m.prop.should.eql 2
                done()


        it 'can set properties to not be enumerated by serializers', (done) -> 

            Message = message 
                properties:
                    internalCode: 
                        default: 'R'
                        hidden:  true

            Message.create().then (m) ->
                m.internalCode.should.equal 'R'
                m.internalCode = 'X'
                m.internalCode.should.equal 'X'
                m.should.eql {}
                done()


        it 'calls beforeCreate ahead of property assignment', (done) -> 

            Message = message 
                beforeCreate: (msg, done) -> 
                    msg.preAssigned = 'value'
                    done()

                properties:
                    internalCode: 
                        default: 'R'
                        hidden:  true

            Message.create().then (m) ->

                m.should.eql preAssigned: 'value'
                m.internalCode.should.equal 'R'
                done()


        it 'calls afterCreate after property assignment', (done) -> 

            Message = message 
                properties:
                    internalCode: 
                        default: 'R'
                        hidden:  true
                afterCreate: (msg, done) ->  
                    msg.one++
                    done()

            Message.create
                one: 1
                two: 2
            .then (m) -> 
                m.one.should.equal 2
                done()


xdescribe 'Message', -> 

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
