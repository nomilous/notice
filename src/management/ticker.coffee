
testable = undefined
module.exports._ticker = -> testable
module.exports.ticker  = (config = {}) ->

    config.ticks ||= {}

    testable = local = 

        notifier: undefined
        timers: {}
        register: (notifier, opts = {}) -> 

            local.notifier = notifier
            local.timers[notifier.title] = timers = {}

            list = {}
            list[key] = config.ticks[key] for key of config.ticks
            list[key] = opts.ticks[key] for key of opts.ticks

            for key of list

                do (key) -> 

                    tick = list[key]
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
