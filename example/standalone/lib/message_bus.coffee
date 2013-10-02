notice = require '../../../lib/notice'

MessageBus1 = notice() # default messages config
MessageBus2 = notice  

    messages: 

        #
        # bus2 defines messages
        #

        update: 
            afterCreate: (msg, next) -> 
                msg.createdAt = new Date

                #
                # create a watched property on the msg
                #

                msg.set
                    watched: (property, change, object) -> 
                        console.log 'changed property:', property, change
                    state: 'pending'
                next()

module.exports.bus1 = MessageBus1.create 'app_name::bus1'
module.exports.bus2 = MessageBus2.create 'app_name::bus2'
