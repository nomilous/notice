inflection     = require 'inflection'
module.exports = 

    find: (source) -> 

        try

            #
            # users can define the actual messenger
            #

            messenger = require "#{  process.env.HOME  }/.notice/messengers"

            unless typeof messenger[source] == 'function'

                return null

            return messenger[source]


        catch error

            #
            # if they want to
            #

            null
