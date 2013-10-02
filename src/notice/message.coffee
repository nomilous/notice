{deferred, pipeline} = require 'also'

testable                = undefined
module.exports._message = -> testable
module.exports.message  = (type, config = {}) ->

    thisConfig = {}
    try thisConfig = config.messages[type]

    local = 

        Message: 

            create: deferred ({resolve, reject, notify}, properties = {}) -> 

                before = deferred ({resolve, reject}, msg) -> 

                    #
                    # builtin type properties
                    #

                    Object.defineProperty msg, '_type', 
                        enumerable: false
                        writable: false
                        value: type

                    return resolve msg unless typeof thisConfig.beforeCreate == 'function' 
                    thisConfig.beforeCreate msg, (error) -> 
                        if error? then return reject error
                        resolve msg

                assign = (msg) -> 
                    msg[key] = properties[key] for key of properties
                    return msg

                after = deferred ({resolve, reject}, msg) -> 
                    return resolve msg unless typeof thisConfig.afterCreate == 'function' 
                    thisConfig.afterCreate msg, (error) -> 
                        if error? then return reject error
                        resolve msg
                    
                pipeline([

                    (   ) -> before { }
                    (msg) -> assign msg
                    (msg) -> after  msg

                ]).then resolve, reject, notify
        

    testable = local

    return local.Message

