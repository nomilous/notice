config = require('./configure').config

module.exports = 

    sendMessage: -> 

        config.messenger

            source: config.source
