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

            for key of properties
                unless key == type
                    cap[key] = properties[key]
                    continue

                assign = {}
                assign[key]      = properties[key]
                assign.protected = true
                cap.set assign

            try if local.config.before

                done = -> resolve cap
                return local.config.before done, cap

            return resolve new local.Capsule
