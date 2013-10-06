{deferred, pipeline} = require 'also'
{capsule} = require './capsule'

testable                = undefined
module.exports._message = -> testable
module.exports.message  = (type, config = {}) ->

    thisConfig = {}
    try thisConfig = config.messages[type]

    local = 

        Capsule: capsule config

        Message: 

            create: deferred ({resolve, reject, notify}, properties = {}) -> 

                before = deferred ({resolve, reject}, capsule) -> 

                    capsule.set
                        _type: type
                        protected: true
                        hidden: true

                    #
                    # capsule[type] is immutable
                    # --------------------------
                    # 
                    # * `capsule.event = 'renamed'` does nothing if capsule._type is 'event' 
                    # * middlewares can optionally set it to hidden if necessary for serialization
                    # 

                    if properties[type]? 
                        typeValue = {}
                        typeValue[type] = properties[type]
                        typeValue.protected = true
                        capsule.set typeValue

                    return resolve capsule unless typeof thisConfig.beforeCreate == 'function' 
                    thisConfig.beforeCreate( 
                        (error) -> 
                            if error? then return reject error
                            resolve capsule
                        capsule
                    )

                assign = (capsule) -> 
                    capsule[key] = properties[key] for key of properties
                    return capsule

                after = deferred ({resolve, reject}, capsule) -> 
                    return resolve capsule unless typeof thisConfig.afterCreate == 'function' 
                    thisConfig.afterCreate( 
                        (error) -> 
                            if error? then return reject error
                            resolve capsule
                        capsule
                    )
                    
                pipeline([

                    (       ) -> new local.Capsule
                    (capsule) -> before capsule
                    (capsule) -> assign capsule
                    (capsule) -> after  capsule

                ]).then resolve, reject, notify
        

    testable = local

    return local.Message

