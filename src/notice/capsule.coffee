testable                = undefined
module.exports._capsule = -> testable
module.exports.capsule  = (config = {}) ->

    testable = class Capsule

        set: (opts) -> 
 
            null for key of opts
            @[key] = opts[key]
            Object.defineProperty @, key, 
                writable:   not opts.protected
                enumerable: not opts.hidden
