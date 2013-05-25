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
# TODO: optional/configurable STD pipes
# 

notice.stdout   = process.stdout
notice.stderr   = process.stderr

#
# notice() is the exported module object
#

module.exports   = notice

