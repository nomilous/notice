try 

    #
    # first try to load user's handler module from $HOME/.notice/handler 
    # 

    handler = require "#{process.env.HOME}/.notice/handler"

catch error

    #
    # fall back to default handler
    #

    handler = (notification) ->

            test = 'default notification handler'


module.exports = handler
