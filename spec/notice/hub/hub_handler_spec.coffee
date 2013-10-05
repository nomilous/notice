should      = require 'should'
{handler, _Handler, _handler} = require '../../../lib/notice/hub/hub_handler'

describe 'handler', -> 

    it 'is a Handler factory', (done) -> 

        HandlerClass = handler()

        HandlerClass.create.should.be.an.instanceof Function
        done()

    it 'creates a handler', (done) -> 

        HandlerClass = handler()
        instance = HandlerClass.create()

        instance.handshake.should.be.an.instanceof  Function
        instance.resume.should.be.an.instanceof     Function
        instance.disconnect.should.be.an.instanceof Function
        done()


    context 'disconnect', -> 

    context 'handshake', -> 

    context 'resume', -> 


