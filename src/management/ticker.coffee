
testable = undefined
module.exports._ticker = -> testable
module.exports.ticker  = (config = {}) ->

    testable = local = 

        notifier: undefined
        timers: {}
        register: (notifier, opts) -> 

            local.notifier = notifier
            local.timers[notifier.title] = timers = {}

            for key of opts.ticks

                do (key) -> 

                    tick = opts.ticks[key]
                    tick.interval ?= 1000
                    tick.seq = 0

                    timers[key] = 

                        interval: tick.interval
                        timer: setInterval ( ->

                            notifier.$$tick key, seq: tick.seq++

                        ), tick.interval

            #
            # TODO: tick capsule are not sent across the socket
            #

    api = 

        register: local.register
