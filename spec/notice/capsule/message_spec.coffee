#require('nez').realize 'Message', (Message, test, context, should) -> 
    
{_message, message} = require '../../../lib/notice/capsule/message'
{_Capsule} = require '../../../lib/notice/capsule/capsule'
should  = require 'should'

describe 'Message', -> 

    context 'factory', -> 

        it 'creates a MessageType definition', (done) -> 

            Alert = message 'alert'
            Alert.create.should.be.an.instanceof Function
            done()


    context 'create()', ->

        it 'is used to create a message for sending onto the middleware pipeline', -> 
        it 'is asynchronous to enable www/DB involvement at creation', ->

        it 'is asynchronous, returning a promise', (done) -> 

            Message = message 'type'
            Message.create( property: 'value' ).then (m) -> 

                m._type.should.equal 'type'
                m.should.eql property: 'value'
                done()


        it 'creates a message as Capsule instance', (done) -> 

            Message = message 'type'
            Message.create().then (m) -> 

                m.set.should.be.an.instanceof Function
                #m.should.be.an.instanceof _Capsule()
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

        it 'has immutable type value', (done) -> 

            Message = message 'alert'
            Message.create( alert: 'bang' ).then (m) -> 

                m.should.eql alert: 'bang'
                m.alert = 'plop'
                m.alert.should.eql 'bang'
                done()


        it 'calls beforeCreate ahead of property assignment', (done) -> 

            Message = message 'type',
                capsule: type: beforeCreate: (done, msg) -> 
                    msg.preAssigned = 'value'
                    done()

            Message.create( ).then (m) ->
                m.should.eql preAssigned: 'value'
                done()

        it 'sets _type before beforeCreate', (done) -> 

            Message = message 'type',
                capsule: type: beforeCreate: (next, msg) -> 
                    msg._type.should.equal 'type'
                    done()

            Message.create()

        it 'calls afterCreate after property assignment', (done) -> 

            Message = message 'type',
                capsule: type: afterCreate: (next, msg) ->  
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
                capsule: type: beforeCreate: (done, msg) ->  
                    done new Error 'darn, no DB to save initial message state'

            Message.create( 'helloo-oo-oo': 'bat flies out' ).then (->), (error) ->

                error.message.should.equal 'darn, no DB to save initial message state'
                done()

