notice = require '../../../lib/notice'

GenericHub = notice.hub
    
    api: 
        listen: port: 9999
        authenticate:
            username: 'user'
            password: ''

genericHub1 = GenericHub.create

    title: 'Bus 1'
    uuid:  1

    ticks: 
        SlowTick:
            interval: 1000

    (err, hub) -> 

        if err? 
            console.log err
            process.exit 1

        hub.use 
            title: 'Middleware 1'
            (next, capsule, traversal) -> 
                console.log capsule
                next()


genericHub2 = GenericHub.create

    title: 'Bus 2'
    uuid:  2

    ticks: 
        FastTick:
            interval: 1

    (err, hub) -> 

        if err? 
            console.log err
            process.exit 1

        # hub.use 
        #     title: 'Middleware 1'
        #     (next, capsule, traversal) -> 
        #         console.log capsule
        #         next()

