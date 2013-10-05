testable                = undefined
module.exports._capsule = -> testable
module.exports.capsule  = (config = {}) ->

    testable = class Capsule

        #
        # ./message  - creates one of these
        # ./notifier - pushes it down the middleware pipeline
        #

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
                            msg:      @

            @[key] = opts[key]

            if opts.hidden? 
                Object.defineProperty @, key, 
                    enumerable: not opts.hidden

            if opts.protected?
                Object.defineProperty @, key, 
                    writable: not opts.protected


        # save:    ->
        # refresh: ->

