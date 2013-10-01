{notifier} = require './notice/notifier'
#client   = require './notice/client'
#hub      = require './notice/hub'

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

#exports.connect = client.connect
#exports.listen  = hub.create

