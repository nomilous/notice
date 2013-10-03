{notifier} = require './notice/notifier'
{client}   = require './notice/client'
{hub}      = require './notice/hub'

#
# standalone
#

module.exports = notifier

#
# default standalone
#

module.exports.create = notifier().create


#
# connected
#
# Notice.connect() connects to notice hub
# Notice.listen()  creates notice hub
# 

module.exports.connect = client().create
module.exports.listen  = hub().create 

