configure = require './notice/configure'
notify    = require './notice/notify'

#
# notice is the send() function
#

notice           = notify.send

#
# it has additional functions nested as properties 
#

notice.configure = configure
notice.event     = 

    good:   -> notify.send notify.format tenor: 'good', arguments
    normal: -> notify.send notify.format tenor: 'normal', arguments
    bad:    -> notify.send notify.format tenor: 'bad', arguments

#
# notice() is the exported module object
#

module.exports   = notice

