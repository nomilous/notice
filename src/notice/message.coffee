onceIfString   = require('./decorators').onceIfString

module.exports = class Message

    #constructor: (properties = {}, composition = {}) -> 
    constructor: ( properties = {} ) -> 

        context = {}

        # 
        # message composition: 
        # 
        #  - set once / then read only properties
        #

        composition = 

            context: ['label', 'description']


        for name in composition.context

            do (name) => 

                Object.defineProperty @, name, 

                    get: -> context[name] || '' 
                    set: onceIfString (value) -> context[name] = value

                    # 
                    # have another stab at this (for validations), later... 
                    # 
                    # set: onceIf 'string', (value) -> context.label = value
                    # 

            @[name] = properties[name]

        
        Object.defineProperty this, 'context',

            #
            # this can likely be improved
            #
            get: -> 
                result = {}
                for name in composition.context
                    result[name] = context[name]
                result

