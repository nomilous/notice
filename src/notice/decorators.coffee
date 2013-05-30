support        = require './support'
module.exports = 

    #
    #  - ensures fn() is only run once
    #    and only when passed a string
    #

    onceIfString: (fn) -> 
        do (done = false) -> 
            (value) -> unless done 
                if done = typeof value is 'string'
                    fn value


    #
    # - ensures the provided fn is a Function
    # - the decorated function returns false if not
    # 

    isFn: (fn) -> 
        do -> (value) ->
            return fn value if typeof value is 'function'
            return false

    #
    # - ensures the provided fn is valid message middleware
    # - the decorated function returns false if not
    # 

    isMiddleware: (fn) -> 
        (middleware) -> 
            unless next = support.argsOf( middleware )[1]
                return -> false
            unless support.callsFn next, middleware
                return -> false
            fn middleware

