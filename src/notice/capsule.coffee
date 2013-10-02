testable                = undefined
module.exports._capsule = -> testable
module.exports.capsule  = (config = {}) ->

    testable = class Capsule

        set: (opts) -> 

            local = {}
            break for key of opts

            if opts.watched? 
                if opts.protected

                    process.stderr.write "cannot watch protected property:#{key}"

                else Object.defineProperty @, key, 
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


        # save:    ->
        # refresh: ->

