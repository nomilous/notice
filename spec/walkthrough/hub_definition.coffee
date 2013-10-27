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
            interval: 1 # quite high frequency
