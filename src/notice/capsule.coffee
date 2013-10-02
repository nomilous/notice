testable                = undefined
module.exports._capsule = -> testable
module.exports.capsule  = (config = {}) ->

    testable = class Capsule

        set: (opts) -> 
 
            null for key of opts
            @[key] = opts[key]

            if opts.hidden? 
                Object.defineProperty @, key, 
                    enumerable: not opts.hidden

            if opts.protected?
                Object.defineProperty @, key, 
                    writable: not opts.protected
