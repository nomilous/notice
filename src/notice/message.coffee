#
# function decorator 
#  - ensures fn() is only run once
#    and only when passed a string
#

onceIfString = (fn) -> 
    do (done = false) -> 
        (value) -> unless done 
            if done = typeof value is 'string'
                fn value



module.exports = class Message

    constructor: (label, description) -> 

        content = {}

        #
        # set once (read only properties)
        #
        # - label
        # - description
        # - type
        #

        Object.defineProperty this, 'label', 
            get: -> content.label   
            set: onceIfString (value) -> content.label = value
            # 
            # couldn't pull this one off:
            # 
            # set: onceIf 'string', (value) -> content.label = value

        Object.defineProperty this, 'description', 
            get: -> content.description
            set: onceIfString (value) -> 
                content.description = value 


        @label       = label
        @description = description

        
        Object.defineProperty this, 'content',
            get: -> 
                label:       content.label
                description: content.description

