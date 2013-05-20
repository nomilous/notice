module.exports = -> 

    try

        return require "#{  process.env.HOME  }/.notice/messenger"

    catch error

        return null
