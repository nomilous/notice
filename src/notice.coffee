module.exports = notice = require('./notice/notify').send

Object.defineProperty notice, 'configure', 

    get: -> require './notice/configure'
    enumerable: true

