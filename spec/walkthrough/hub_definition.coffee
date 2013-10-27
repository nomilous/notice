{hub}  = require '../../lib/notice'

module.exports = (port) -> return hub

    api: 
        listen: port: port
        authenticate: (user, pass, callback) ->
            #
            # insert async auth step here
            #
            callback null, 
                username: user
                roles: ['pretend']

    ticks: 
        onYourMarks:
            interval: 1000 # quite high frequency
