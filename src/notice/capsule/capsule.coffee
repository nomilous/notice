Testable                = undefined
testable                = undefined
module.exports._Capsule = -> Testable
module.exports._capsule = -> testable

module.exports.capsule  = (config = {}) ->


    Testable = factory = 

        create: (opts = {}) ->

            testable = internal = 

                uuid: opts.uuid
                hidden: {}
                protected: {}


            external = {}


            Object.defineProperty external, '$$uuid', 
                enumarable: false
                get: -> internal.uuid
                set: (value) -> internal.uuid = value unless internal.uuid?


            Object.defineProperty external, '$$set',
                enumarable: false
                get: -> (hash) -> 

                    break for firstKey of hash
                    return if firstKey is 'uuid'
                    return if firstKey is 'hidden'
                    return if firstKey is 'protected'

                    if hash.watched? 
                        hash.watched.count = 0
                        if hash.protected
                            process.stderr.write "cannot watch protected property:#{firstKey}"
                        else 
                            Object.defineProperty external, firstKey,
                                enumerable: true
                                get: -> internal[firstKey]
                                set: (value) -> 
                                    previous = internal[firstKey]
                                    internal[firstKey] = value

                                    unless hash.watched.count == 0
                                        hash.watched
                                            property: firstKey
                                            from:     previous
                                            to:       value
                                            capsule:  external
                                    hash.watched.count++

                    external[firstKey] = hash[firstKey]

                    if hash.hidden?
                        if hash.hidden then internal.hidden[firstKey] = 1
                        else delete internal.hidden[firstKey]
                        Object.defineProperty external, firstKey, 
                            enumerable: not hash.hidden

                    if hash.protected?
                        if hash.protected then internal.protected[firstKey] = 1
                        Object.defineProperty external, firstKey, 
                            writable: not hash.protected



            Object.defineProperty external, '$$all',
                enumarable: false
                get: -> 
                    all = {}
                    all[key] = external[key] for key in (
                        for key of internal.hidden
                            continue if typeof internal[key] is 'function'
                            key 
                    ).concat( for key of external
                        continue if typeof external[key] is 'function'
                        key
                    )
                    all


            Object.defineProperty external, '$$protected',
                enumerable: false
                get: -> internal.protected


            Object.defineProperty external, '$$hidden',
                enumerable: false
                get: -> internal.hidden

            return external


