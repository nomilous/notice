module.exports = -> 

    try

        #
        # users define the actual messenger
        #

        require "#{  process.env.HOME  }/.notice/messenger"

    catch error

        #
        # if they want to
        #

        null
