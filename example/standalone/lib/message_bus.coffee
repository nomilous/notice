notice = require '../../../lib/notice'

Bus1 = notice() # default messages config
Bus2 = notice  

    messages: 

        #
        # bus2 defines messages
        #

        update: 
            properties:
                routingCode: default: '∆', hidden:  true
            afterCreate: (msg, next) -> 
                msg.createdAt = new Date
                next()

module.exports.bus1 = Bus1.create 'app_name::bus1'
module.exports.bus2 = Bus2.create 'app_name::bus2'
