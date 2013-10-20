{notifier} = require './notice/notifier'
{client}   = require './notice/client'
{hub}      = require './notice/hub'
tools      = require './tools'

#
# standalone
#

module.exports = notifier

#
# default standalone
#

module.exports.create = notifier().create


#
# default connected
#
# Notice.connect() connects to notice hub
# Notice.listen()  creates notice hub
# 

module.exports.connect = client().create
module.exports.listen  = hub().create

#
# factories
#

module.exports.client  = client
module.exports.hub     = hub

#
# Notables
#

module.exports.tools  = tools
