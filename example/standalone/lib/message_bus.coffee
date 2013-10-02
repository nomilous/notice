notice = require '../../../lib/notice'

MessageBus1 = notice() # default messages config
MessageBus2 = notice  

    messages: 

        #
        # bus2 defines 'update' message
        #

        update: 
            afterCreate: (msg, next) -> 
                msg.createdAt = new Date

                #
                # create a watched property on the 'update' msg
                #

                msg.set
                    state: 'pending'
                    watched: (property, change, object) -> 
                        console.log 'changed property:', property, change
                    
                next()

module.exports.bus1 = MessageBus1.create 'app_name::bus1'
module.exports.bus2 = MessageBus2.create 'app_name::bus2'
