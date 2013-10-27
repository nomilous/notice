notice = require '../../../lib/notice'

MessageBus1 = notice() # default capsules config
MessageBus2 = notice  

    capsules: 

        #
        # bus2 defines 'update' capsule
        #

        update: 
            afterCreate: (next, capsule) -> 
                capsule.createdAt = new Date

                #
                # create a watched property on the 'update' capsule
                #

                capsule.$set
                    state: 'pending'
                    watched: (property, change, object) -> 
                        console.log 'changed property:', property, change
                    
                next()

module.exports.bus1 = MessageBus1.create 'app_name::bus1'
module.exports.bus2 = MessageBus2.create 'app_name::bus2'
