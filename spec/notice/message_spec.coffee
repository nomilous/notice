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

        it 'has immutable _type that defaults to event', (done) -> 

            Message = message()
            Message.create 
                property1: 'value1'
            .then (m) -> 
                m._type = 'lkmsldfdf'
                m._type.should.equal 'event'
                done()

        it 'can set _type on create', (done) ->

            Message = message()
            Message.create 
                _type: 'TYPE'
            .then (m) -> 
                m._type.should.equal 'TYPE'
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

            Message.create( ).then (m) ->
                m.should.eql preAssigned: 'value'
                m.internalCode.should.equal 'R'
                done()

        it 'sets _type before beforeCreate', (done) -> 

            Message = message 
                beforeCreate: (msg, next) -> 
                    msg._type.should.equal 'event'
                    done()

            Message.create()

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


        it 'beforeCreate and afterCreate can fail the message creation', (done) -> 

            Message = message 
                beforeCreate: (msg, done) ->  
                    done new Error 'darn, no DB to save initial message state'

            Message.create( 'helloo-oo-oo': 'bat flies out' ).then (->), (error) ->

                error.message.should.equal 'darn, no DB to save initial message state'
                done()

