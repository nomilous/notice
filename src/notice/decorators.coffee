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
    # - ensures the provided arg is a Function
    # - returns false if not
    # 

    isFn: (fn) -> 
        do -> (value) ->
            return fn value if typeof value is 'function'
            return false

