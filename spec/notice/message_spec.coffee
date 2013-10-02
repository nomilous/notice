#require('nez').realize 'Message', (Message, test, context, should) -> 
    
{_message, message} = require '../../lib/notice/message'
should  = require 'should'

describe 'Message', -> 

    context 'factory', -> 

        it 'creates a MessageType definition', (done) -> 

            Alert = message 'alert'
            Alert.create.should.be.an.instanceof Function
            done()


    context 'create()', ->

        it 'is asynchronous, returning a promise', (done) -> 

            Message = message 'type'
            Message.create( property: 'value' ).then (m) -> 
            
                m._type.should.equal 'type'
                m.should.eql property: 'value'
                done()


        it 'is created with a set of properties', (done) -> 

            Message = message 'type'

            Message.create
                property1: 'value1'
                property2: 'value2'

            .then (m) -> m.should.eql
                property1: 'value1'
                property2: 'value2'
                done()


        it 'has immutable _type that defaults to event', (done) -> 

            Message = message 'type'
            Message.create 
                property1: 'value1'
            .then (m) -> 
                m._type = 'lkmsldfdf'
                m._type.should.equal 'type'
                done()


        it 'calls beforeCreate ahead of property assignment', (done) -> 

            Message = message 'type',
                messages: type: beforeCreate: (msg, done) -> 
                    msg.preAssigned = 'value'
                    done()

            Message.create( ).then (m) ->
                m.should.eql preAssigned: 'value'
                done()

        it 'sets _type before beforeCreate', (done) -> 

            Message = message 'type',
                messages: type: beforeCreate: (msg, next) -> 
                    msg._type.should.equal 'type'
                    done()

            Message.create()

        it 'calls afterCreate after property assignment', (done) -> 

            Message = message 'type',
                messages: type: afterCreate: (msg, done) ->  
                    msg.one++
                    done()

            Message.create
                one: 1
                two: 2
            .then (m) -> 
                m.one.should.equal 2
                done()


        it 'beforeCreate and afterCreate can fail the message creation', (done) -> 

            Message = message 'type',
                messages: type: beforeCreate: (msg, done) ->  
                    done new Error 'darn, no DB to save initial message state'

            Message.create( 'helloo-oo-oo': 'bat flies out' ).then (->), (error) ->

                error.message.should.equal 'darn, no DB to save initial message state'
                done()

