Testable                = undefined
testable                = undefined
module.exports._Capsule = -> Testable
module.exports._capsule = -> testable

module.exports.capsule  = (config = {}) ->


    Testable = factory = 

        create: (opts = {}) ->

            testable = internal = 

                uuid: opts.uuid

            external = {}

            Object.defineProperty external, '$$uuid', 
                enumarable: false
                get: -> internal.uuid
                set: (value) -> internal.uuid = value unless internal.uuid?

            Object.defineProperty external, '$$set',
                enumarable: false
                get: -> (hash) -> 

                    break for firstKey of hash
                    internal[firstKey] = hash[firstKey]

                    Object.defineProperty external, firstKey, 
                        get: -> internal[firstKey]

































    return factoryApi = 

        create: factory.create


    #
    # re-implement as configged enclosure instead of coffee class
    # to fix bug1
    # 



    Testable = class Capsule   # latest Definition available for testing

        #
        # ./lifecycle  - creates one of these
        # ../notifier  - pushes it down the middleware pipeline
        #

        constructor: (params = {}) -> 

            uuid = params.uuid

            @$$hidden = {}
            Object.defineProperty @, '$$hidden', 
                enumerable: false

            @$$protected = {}
            Object.defineProperty @, '$$protected', 
                enumerable: false

            Object.defineProperty @, '$$uuid', 
                enumarable: false
                get: -> uuid
                set: (value) -> uuid = value unless uuid?


            Object.defineProperty @, '$$all', 
                enumerable: false
                get: => 
                    allProperties = {}
                    allProperties[key] = @[key] for key in (
                        for key of @$$hidden
                            continue if typeof @[key] is 'function'
                            key 
                    ).concat( 
                        for key of @
                            continue if typeof @[key] is 'function'
                            key
                    )
                    allProperties

            testable = @  # latest instance available for testing


        $$set: (opts) -> 

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
                if opts.hidden then @$$hidden[key] = 1
                else delete @$$hidden[key]
                Object.defineProperty @, key, 
                    enumerable: not opts.hidden

            if opts.protected?
                if opts.protected then @$$protected[key] = 1
                Object.defineProperty @, key, 
                    writable: not opts.protected

