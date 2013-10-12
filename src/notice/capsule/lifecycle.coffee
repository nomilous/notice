{deferred} = require 'also'
{capsule}  = require './capsule'

module.exports.lifecycle  = (type, config = {}) -> 

    local = 

        cache:  {}
        config: try config.capsule[type]

        Capsule: capsule()

        create: deferred ({resolve}) -> 

            try if local.config.before

                return local.config.before ->
                    
                    resolve new local.Capsule

            return resolve new local.Capsule




