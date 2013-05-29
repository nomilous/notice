module.exports = class Message

    constructor: (label, description) -> 

        content = 
            label: if typeof label is 'string' then label
            description: if typeof description is 'string' then description

        Object.defineProperty this, 'content',
            get: -> 
                label:       content.label
                description: content.description

        #
        # set once (read only properties)
        #
        # - label
        # - description
        #

        Object.defineProperty this, 'label', 
            get: -> content.label
            set: (value) -> 
                unless content.label?
                    if typeof value is 'string'
                        content.label = value

        Object.defineProperty this, 'description', 
            get: -> content.description
            set: (value) -> 
                unless content.description?
                    if typeof value is 'string'
                        content.description = value 
