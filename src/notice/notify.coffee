os     = require 'os'
config = require('./configure').config

module.exports = 

    send: (label, description) -> 

        content = {}

        if typeof label == 'string'
            content.label = label
        else 
            content = label

        if typeof description == 'string'
            content.description = description

        message = 

            context: 
                 type: 'event'

            source:
                time: Date.now()
                ref: config.source

        message.content = content

        config.messenger message


