testable                = undefined
module.exports._capsule = -> testable
module.exports.capsule  = (config = {}) ->

    testable = class Capsule

        set: (opts) -> 

            local = {}
            null for key of opts

            if opts.watched?
                Object.defineProperty @, key, 
                    get: -> local[key]
                    set: (value) => 
                        previous = local[key]
                        local[key] = value
                        opts.watched key, from: previous, to: value, @

            @[key] = opts[key]

            if opts.hidden? 
                Object.defineProperty @, key, 
                    enumerable: not opts.hidden

            if opts.protected?
                Object.defineProperty @, key, 
                    writable: not opts.protected

