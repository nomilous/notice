{v1}       = require 'node-uuid'
{deferred} = require 'also'
{capsule}  = require './capsule'

module.exports.lifecycle  = (type, config = {}) -> 

    local = 

        Capsule: capsule config
        config:  try config.capsule[type]
        cache:   {}


        create: deferred ({resolve, reject}, properties = {}) -> 

            cap = new local.Capsule
            cap.set 
                $$type: type
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

                done = -> 
                    cap._uuid = v1() unless cap._uuid?
                    resolve cap

                try 
                    return local.config.before done, cap
                catch error 
                    return reject error


            cap._uuid = v1() unless cap._uuid?
            return resolve cap
