notify = require './notice/notify'

module.exports = notice = notify.send

Object.defineProperty notice, 'configure', 

    get: -> require './notice/configure'
    enumerable: true


notice.event = 

    good:   -> notify.send notify.format tenor: 'good', arguments
    normal: -> notify.send notify.format tenor: 'normal', arguments
    bad:    -> notify.send notify.format tenor: 'bad', arguments

