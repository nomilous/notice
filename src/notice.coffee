module.exports = notice = require('./notice/notify').send

Object.defineProperty notice, 'configure', 

    get: -> require './notice/configure'
    enumerable: true


#
# helper functions
#

Object.defineProperty notice, 'sublime', 
    enumerable: true
    get: -> (msg = {}) -> 
        msg.stature = 'sublime'
        notice msg

Object.defineProperty notice, 'fantastic', 
    enumerable: true
    get: -> (msg = {}) -> 
        msg.stature = 'fantastic'
        notice msg

Object.defineProperty notice, 'nice', 
    enumerable: true
    get: -> (msg = {}) -> 
        msg.stature = 'nice'
        notice msg

Object.defineProperty notice, 'fine', 
    enumerable: true
    get: -> (msg = {}) -> 
        msg.stature = 'fine'
        notice msg

Object.defineProperty notice, 'poor', 
    enumerable: true
    get: -> (msg = {}) -> 
        msg.stature = 'poor'
        notice msg

Object.defineProperty notice, 'ghastly', 
    enumerable: true
    get: -> (msg = {}) -> 
        msg.stature = 'ghastly'
        notice msg

Object.defineProperty notice, 'horrendous', 
    enumerable: true
    get: -> (msg = {}) -> 
        msg.stature = 'horrendous'
        notice msg


