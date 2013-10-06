notice = require '../lib/notice'
should = require 'should'

describe 'standalone default notifier', -> 

    it """

        * It is created with an origin name
        * Has a middleware registrar.
        * It can send events down the middleware pipeline.
        * Each message is assigned the _type (hidden property)
        * The event sender receives the final message or error
          from the pipeline.
        * The sender can use a promise instead of callback to 
          receive the final message.

    """, (done) -> 


        send = notice.create 'origin name'
        
        send.use title: 'testing 1', (done, msg) -> 
            msg._type.should.equal 'event'
            msg.modified = true
            done()
        
        send.use title: 'testing 2', (done, msg) ->
            throw 'π' if msg.thisFails
            done()

        send.event 'event name', payload: 1, more: 2, (err, result) -> 
            result.should.eql 
                event:   'event name'
                payload:  1
                more:     2
                modified: true

            send.event 'event name', thisFails: true, (err, result) -> 
                err.should.equal 'π'

                send.event 'event name', 
                    payload: 1
                    more:    2
                .then( 
                    (msg) -> done()
                    (err) -> 
                )

describe 'standalone configured notifier', -> 
    
    it """

        * A notifier Definition is configured with message definitions
        * The reslting Definition can be used to create notifiers of the
          defined type
        * Each message type is emitted through a created function by the 
          same name.
        * Message definitions can be assigned beforeCreate and afterCreate
          hooks to predefine message properties ahead of the middleware 
          traveral.

    """, (done) -> 

        seq = 0
        Messenger = notice 
            messages: 
                messageTypeName:
                    beforeCreate: (done, msg) -> 
                        msg.sequence = seq++
                        done()

        instance = Messenger.create 'origin name'
        instance.use.should.be.an.instanceof Function
        instance.messageTypeName( 'messageTypeValue' ).then (m) -> 
            m._type.should.equal 'messageTypeName'
            m.should.eql 
                messageTypeName: 'messageTypeValue'
                sequence: 0
            done()
