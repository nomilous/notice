onceIfString   = require('./decorators').onceIfString

module.exports = class Message

    #constructor: (properties = {}, composition = {}) -> 
    constructor: ( properties = {} ) -> 

        content = {}

        # 
        # message composition: 
        # 
        #  - set once / then read only properties
        #

        composition = 

            content: ['label', 'description']


        for name in composition.content

            do (name) => 

                Object.defineProperty @, name, 

                    get: -> content[name] || '' 
                    set: onceIfString (value) -> content[name] = value

                    # 
                    # have another stab at this (for validations), later... 
                    # 
                    # set: onceIf 'string', (value) -> content.label = value
                    # 

            @[name] = properties[name]

        
        Object.defineProperty this, 'content',

            #
            # this can likely be improved
            #
            get: -> 
                result = {}
                for name in composition.content
                    result[name] = content[name]
                result

