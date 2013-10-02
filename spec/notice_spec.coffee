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
        
        send.use (msg, next) -> 
            msg._type.should.equal 'event'
            msg.modified = true
            next()
        
        send.use (msg, next) ->
            throw 'π' if msg.thisFails
            next()

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
                    beforeCreate: (msg, done) -> 
                        msg.sequence = seq++
                        done()

        instance = Messenger.create 'origin name'
        instance.use.should.be.an.instanceof Function
        instance.messageTypeName( 'messageTypeValue' ).then (m) -> 
            m.should.eql 
                messageTypeName: 'messageTypeValue'
                sequence: 0
            done()




return



should = require 'should'
Notice = require '../lib/notice'

xdescribe 'Notice', ->


    it 'is a (messaging|????ing) middleware pipeline', (done) -> 


        #
        # create the notifier / pipeline input
        #

        notice = Notice.create 'Origin System'


        #
        # register some middleware
        #

        notice.use (msg, next) -> 

            msg.key1 = 'VALUE1'
            next()

        notice.use (msg, next) -> 

            msg.key2 = 'VALUE2'
            next()


        #
        # send an event down the pipeline
        #

        sent = notice.event.good 'title', 'description'



        #
        # it returned a promise 
        #

        sent.then( 

            (finalMessage) -> 

                finalMessage.content.should.eql

                    context:
                        title:       'title'
                        description: 'description'
                        origin:      'Origin System'
                        type:        'event'
                        tenor:       'good'

                    payload:
                        key1: 'VALUE1'
                        key2: 'VALUE2'

                done()


            (error) -> 

        )


    it 'allows multiple sources', (done) -> 

        source1 = Notice.create 'Source 1'
        source2 = Notice.create 'Source 2'

        MESSAGES = {}

        source1.use (msg, next) -> 

            MESSAGES[msg.context.origin] = msg
            next()

        source2.use (msg, next) -> 

            MESSAGES[msg.context.origin] = msg
            next()

        sent1 = source1.event.good 'title', 'description'
        sent2 = source2.event.good 'title', 'description'

        sent2.then -> 

            should.exist MESSAGES['Source 1']
            should.exist MESSAGES['Source 2']
            done()


