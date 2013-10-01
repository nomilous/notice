{deferred, pipeline} = require 'also'

testable                = undefined
module.exports._message = -> testable
module.exports.message  = (config = {}) ->

    local = 

        Message: 

            create: deferred ({resolve, reject, notify}, properties = {}) -> 

                before = deferred ({resolve, reject}, msg) -> 

                    #
                    # builtin properties
                    #

                    properties._type = 'event' unless properties._type?
                    Object.defineProperty msg, '_type', 
                        enumerable: false
                        writable: false
                        value: properties._type

                    return resolve msg unless typeof config.beforeCreate == 'function' 
                    config.beforeCreate msg, (error) -> 
                        if error? then return reject error
                        resolve msg

                assign = (msg) -> 
                    for key of config.properties
                        continue if key == '_type'
                        if config.properties[key].default?
                            msg[key] = config.properties[key].default
                            if config.properties[key].hidden
                                Object.defineProperty msg, key, 
                                    enumerable: false
                    msg[key] = properties[key] for key of properties
                    return msg

                after = deferred ({resolve, reject}, msg) -> 
                    return resolve msg unless typeof config.afterCreate == 'function' 
                    config.afterCreate msg, (error) -> 
                        if error? then return reject error
                        resolve msg
                    
                pipeline([

                    (   ) -> before { }
                    (msg) -> assign msg
                    (msg) -> after  msg

                ]).then resolve, reject, notify
        

    testable = local

    return local.Message

