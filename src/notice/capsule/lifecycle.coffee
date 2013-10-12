{deferred} = require 'also'
{capsule}  = require './capsule'

module.exports.lifecycle  = (type, config = {}) -> 

    local = 

        cache:  {}
        config: try config.capsule[type]

        Capsule: capsule()

        create: deferred ({resolve}, properties = {}) -> 

            cap = new local.Capsule
            cap.set 
                _type: type
                protected: true
                hidden: true

            cap[key] = properties[key] for key of properties

            try if local.config.before

                done = -> resolve cap
                return local.config.before done, cap

            return resolve new local.Capsule
