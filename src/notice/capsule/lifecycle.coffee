{v1}       = require 'node-uuid'
{deferred} = require 'also'
{capsule}  = require './capsule'

module.exports.lifecycle  = (type, config = {}) -> 

    local = 

        Capsule: capsule config
        config:  try config.capsule[type]
        cache:   {}


        create: deferred ({resolve, reject}, properties = {}) -> 

            cap = local.Capsule.create()
            cap.$set 
                $type: type
                protected: true
                hidden: true

            for key of properties
                unless key == type
                    cap[key] = properties[key]
                    continue

                assign = {}
                assign[key]      = properties[key]
                assign.protected = true
                assign.hidden    = true if local.config.nondescript 
                cap.$set assign

            unless cap[type]?

                assign = {}
                assign[type] = true
                assign.protected = true
                assign.hidden    = true
                cap.$set assign

            try if local.config.before

                done = -> 
                    cap.$uuid = v1() unless cap.$uuid?
                    resolve cap

                try 
                    return local.config.before done, cap
                catch error 
                    return reject error


            cap.$uuid = v1() unless cap._uuid?
            return resolve cap
