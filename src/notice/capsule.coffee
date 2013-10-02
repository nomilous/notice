testable                = undefined
module.exports._capsule = -> testable
module.exports.capsule  = (config = {}) ->

    testable = class Capsule

        set: (opts) -> 
 
            null for key of opts
            @[key] = opts[key]
