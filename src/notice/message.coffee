onceIfString   = require('./decorators').onceIfString

module.exports = class Message

    #constructor: (properties = {}, composition = {}) -> 
    constructor: ( properties = {} ) -> 

        #
        # TODO: enable flagging a message as 'expects reply'
        # --------------------------------------------------
        #
        # * For the case of standalone, nothing happens
        # 
        # * For the case of client as source, the message resolver 
        #   does not fire till after the hubside roundtrip
        # 
        # * For the case of hub as source, to particular client
        #   same as form client.
        # 
        # * For the case of hub as source broadcasting to all clients
        #   fire the resolver on first response (with taken/missed 
        #   secondary acks back to each respondant)
        # 
        #   eg 
        #   
        #     notice.event( 'distributed assembly', 
        #
        #         expectReply: true
        # 
        #     ).then (msg) -> 
        # 
        #         msg.should.eql
        # 
        #            has:   'gone round trip'
        #            first: 'down the local pipeline'
        #            then:  'down the remote pipeline'
        #            and:   'back again to here'
        #            with:  'all payload ammendents'
        # 
        # 
        # TODO: persistable promises (for scaling the above)
        #

        context = {}

        # 
        # message composition: 
        # 
        #  - set once / then read only properties
        #

        composition = 

            context: ['title', 'description', 'origin', 'type', 'tenor', 'direction']


        reply = undefined


        for name in composition.context

            do (name) => 

                Object.defineProperty @, name, 

                    get: -> context[name] || '' 
                    set: onceIfString (value) -> context[name] = value

                    # 
                    # have another stab at this (for validations), later... 
                    # 
                    # set: onceIf 'string', (value) -> context.label = value
                    # 

        if typeof properties is 'object'

            try for name of properties

                @[name] = properties[name]


        Object.defineProperty this, 'setResponder', 

            #
            # for the hub, assign notifier for messaging the
            # remote client
            #

            set: (value) -> reply = value unless reply?


        Object.defineProperty this, 'event', get: => 

            @title if @type == 'event' 

        Object.defineProperty this, 'info', get: => 

            @title if @type == 'info' 
        
        Object.defineProperty this, 'context',

            #
            # this can likely be improved
            #
            get: -> 
                result = {}
                for name in composition.context
                    result[name] = context[name]

                #
                # access to responder on each msg context 
                #

                result.responder = reply if reply?
                result


        Object.defineProperty this, 'content', 

            get: => 
                result = 
                    context: this.context
                    payload: this
                for name in composition.context
                    result.context[name] = context[name]
                result


        Object.defineProperty this, 'reply', 

            get:         -> reply

