{deferred} = require 'also'
{capsule}  = require './capsule'

module.exports.lifecycle  = (type, config = {}) -> 

    local = 

        cache:  {}
        config: try config.capsule[type]

        Capsule: capsule()

        create: deferred ({resolve}) -> 

            try if local.config.before

                cap = new local.Capsule
                cap.set 
                    _type: type
                    protected: true
                    hidden: true


                done = -> resolve cap
                return local.config.before done, cap

            return resolve new local.Capsule

