uuid = require 'node-uuid'

testable                = undefined
module.exports._capsule = -> testable
module.exports.capsule  = (config = {}) ->

    #
    # TODO: config defined uuid construction
    #

    testable = class Capsule

        #
        # ./message  - creates one of these
        # ./notifier - pushes it down the middleware pipeline
        #

        constructor: (params = {}) -> 

            @_hidden = {}
            Object.defineProperty @, '_hidden', 
                enumerable: false

            @_protected = {}
            Object.defineProperty @, '_protected', 
                enumerable: false

            Object.defineProperty @, '_uuid', 
                enumarable: false
                writable: false
                value: params.uuid || uuid.v1() 

            Object.defineProperty @, 'all', 
                enumerable: false
                get: => 
                    allProperties = {}
                    allProperties[key] = @[key] for key in (
                        for key of @_hidden
                            continue if typeof @[key] is 'function'
                            key 
                    ).concat( 
                        for key of @
                            continue if typeof @[key] is 'function'
                            key
                    )
                    allProperties


        set: (opts) -> 

            local = {}
            break for key of opts

            if opts.watched? 
                if opts.protected

                    process.stderr.write "cannot watch protected property:#{key}"

                else Object.defineProperty @, key, 
                    enumerable: true
                    get: -> local[key]
                    set: (value) => 
                        previous = local[key]
                        local[key] = value

                        #
                        # TODO: Consider enabling access to all hubs in the process
                        #       to the change watcher callback. (switching / routing)
                        #

                        opts.watched 
                            property: key
                            from:     previous
                            to:       value
                            capsule:  @

            @[key] = opts[key]

            if opts.hidden? 
                if opts.hidden then @_hidden[key] = 1
                else delete @_hidden[key]
                Object.defineProperty @, key, 
                    enumerable: not opts.hidden

            if opts.protected?
                if opts.protected then @_protected[key] = 1
                Object.defineProperty @, key, 
                    writable: not opts.protected


        # save:    ->
        # refresh: ->

