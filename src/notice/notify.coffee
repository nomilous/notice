os     = require 'os'
config = require('./configure').config

module.exports = send: (msg = {}) -> 

    msg.source = 

        time: Date.now()
        ref: config.source

    config.messenger msg
