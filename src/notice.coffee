module.exports = notice = require('./notice/notify').sendMessage

Object.defineProperty notice, 'configure', 

    get: -> require './notice/configure'
    enumerable: true
