should      = require 'should'
{handler, _Handler, _handler} = require '../../../lib/notice/hub/hub_handler'

describe 'handler', -> 
    
    beforeEach -> 
        @now = Date.now

    afterEach -> 
        Date.now = @now

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

        beforeEach ->

            HandlerClass = handler()
            @instance    = HandlerClass.create(
                
                hubName    = 'hubname'
                @hubContext = 
                    clients: 
                        SOCKET_ID: 
                            connected:
                                state:   'connected'
                                stateAt: '1'
                    connections: -> # TODO: remove this

            )

        it 'sets the client to disconnected', (done) -> 

            Date.now = -> 2
            handler = @instance.disconnect id: 'SOCKET_ID'
            handler()

            connected = @hubContext.clients.SOCKET_ID.connected
            connected.should.eql 
                state: 'disconnected'
                stateAt: 2
            done()



    context 'handshake', -> 

    context 'resume', -> 


