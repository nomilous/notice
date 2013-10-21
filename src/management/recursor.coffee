module.exports.recurse = recurse = (object, pathArray, accum = {}) -> 

    if pathArray? 
        return accum unless next = pathArray.shift()

    for key of object
        if next? then continue unless key is next
        nested = object[key]
        continue if nested instanceof Array

        if typeof nested is 'function' and nested.$$notice?

            #
            # assign content of $$notable as the hash ""value""
            # for the function, causing it to be listed by the
            # JSON serializer, but with the empty {} as assigned
            # to $$notable functions
            #

            if pathArray
                accum = nested
                continue

            else
                accum[key] = nested.$$notice
                continue

        #
        continue unless typeof nested is 'object'
        #
        #console.log nested
        #

        if pathArray?
            accum = recurse nested, pathArray, accum

        else 
            accum[key] = {}
            recurse nested, null, accum[key]

    return accum


module.exports.recursor = (local, type) -> 
    
    ([uuid, deeper], request, response, statusCode = 200) -> 
    
        return local.methodNotAllowed response unless request.method == 'GET'
        return local.objectNotFound response unless local.hubContext.uuids[uuid]
        notifier = local.hubContext.uuids[uuid]

        if deeper?
            
            fn = recurse notifier.serialize(2)[type], deeper.split '/'
            if typeof fn is 'function'
                return fn {}, (error, result) -> 
                    if error? then return local.respond
                        error: error.toString()
                        500
                    
                    local.respond result, statusCode, response

        else
        
            result = recurse notifier.serialize(2)[type]

        local.respond result, statusCode, response

