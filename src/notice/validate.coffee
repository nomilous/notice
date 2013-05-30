
#
# function decorator 
# 
# - ensures the provided arg is a Function
# - returns false if not
# 

requiresFn = (fn) -> 
    do -> (value) ->
        return fn value if typeof value is 'function'
        return false



module.exports = 

    #
    # (boolean) Validate.middleware( fn )
    # 
    # ensure fn is valid as messenger middleware
    # 

    middleware: requiresFn (fn) -> 

        #
        # pull the args from the function signature
        #

        try

            fnArgs = fn.toString().match(

                /^function\W*\(\W*(.*)\W*,\W*(.*)\W*\)/ 

            )[1..2].map (arg) -> arg.trim()

        catch error 

            return false

        #
        # match for call to next() 
        #

        nextWasCalled = new RegExp "#{fnArgs[1]}\W*\\(\W*\\)"
        return false unless fn.toString().match nextWasCalled
        return true # is valid
