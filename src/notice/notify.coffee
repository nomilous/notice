config = require('./configure').config

module.exports = notify = 

    format: (context, args) -> 

        try return args[0] if args[0].formatted

        content = {}

        if typeof args[0] == 'string'
            content.label = args[0]
        else 
            content = args[0]

        if typeof args[1] == 'string'
            content.description = args[1]

        if typeof context.type == 'undefined'
            context.type = 'event' 

        return {

            context: context
                
            source:
                time: Date.now()
                ref: config.source

            content: content

            formatted: true

        }

    send: (label, description) -> 

        config.messenger notify.format {}, arguments



