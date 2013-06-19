socket = require 'socket.io-client'

module.exports = (opts = {}) -> 

    opts.port      ||=  10001
    opts.hostname  ||= 'localhost'
    opts.transport ||= 'https'

    socket.connect "#{ opts.transport }://#{ opts.hostname }:#{ opts.port }"

