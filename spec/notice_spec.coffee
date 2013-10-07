notice = require '../lib/notice'
should = require 'should'

describe 'standalone default notifier', -> 

    it """

        * It is created with an origin name
        * Has a middleware registrar.
        * It can send capsule down the middleware pipeline.
        * Each capsule is assigned the _type (hidden property)
        * The event sender receives the final capsule or error
          from the pipeline.
        * The sender can use a promise instead of callback to 
          receive the final capsule.

    """, (done) -> 


        send = notice.create 'origin name'
        
        send.use title: 'testing 1', (next, capsule) -> 
            capsule._type.should.equal 'event'
            capsule.modified = true
            next()
        
        send.use title: 'testing 2', (next, capsule) ->
            throw 'π' if capsule.thisFails
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
                    (capsule) -> done()
                    (err) -> 
                )

describe 'standalone configured notifier', -> 
    
    it """

        * A notifier Definition is configured with capsule definitions
        * The reslting Definition can be used to create notifiers of the
          defined type
        * Each capsule type is emitted through a created function by the 
          same name.
        * Casule definitions can be assigned beforeCreate and afterCreate
          hooks to predefine capsule properties ahead of the middleware 
          traveral.

    """, (done) -> 

        seq = 0
        Messenger = notice 
            capsules: 
                capsuleTypeName:
                    beforeCreate: (done, capsule) -> 
                        capsule.sequence = seq++
                        done()

        instance = Messenger.create 'origin name'
        instance.use.should.be.an.instanceof Function
        instance.capsuleTypeName( 'capsuleTypeValue' ).then (m) -> 
            m._type.should.equal 'capsuleTypeName'
            m.should.eql 
                capsuleTypeName: 'capsuleTypeValue'
                sequence: 0
            done()
