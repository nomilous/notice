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

    good:   -> notify.send notify.format {type: 'event', tenor: 'good'}, arguments
    normal: -> notify.send notify.format {type: 'event', tenor: 'normal'}, arguments
    bad:    -> notify.send notify.format {type: 'event', tenor: 'bad'}, arguments

notice.info     = 

    good:   -> notify.send notify.format {type: 'info', tenor: 'good'}, arguments
    normal: -> notify.send notify.format {type: 'info', tenor: 'normal'}, arguments
    bad:    -> notify.send notify.format {type: 'info', tenor: 'bad'}, arguments


#
# perhaps overkill
# standard io - stick to pattern
# 

notice.stdio   =

    good:   -> notify.send notify.format {type: 'stdout', tenor: 'good'}, arguments
    normal: -> notify.send notify.format {type: 'stdout', tenor: 'normal'}, arguments
    bad:    -> notify.send notify.format {type: 'stderr', tenor: 'bad'}, arguments

#
# notice() is the exported module object
#

module.exports   = notice

