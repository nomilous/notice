module.exports.ticks  = (config = {}) ->

    local = 

        notifier: undefined
        timers: {}
        register: (opts, notifier) -> 

            local.notifier = notifier
            local.timers[notifier.title] = timers = {}

            for key of opts.ticks

                do (key) -> 

                    tick = opts.ticks[key]
                    timers[key] = setInterval ( ->

                        notifier.$$tick key

                    ), tick.interval

            #
            # TODO: tick capsule are not sent across the socket
            #