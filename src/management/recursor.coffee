testable = undefined
module.exports._recursor = -> testable
module.exports.recursor  = (local, type) -> 

    testable = ([uuid, deeper], request, response, statusCode = 200) -> 

        return local.methodNotAllowed response unless request.method == 'GET'
        return local.objectNotFound response unless local.hubContext.uuids[uuid]

        notifier    = local.hubContext.uuids[uuid]
        searialized = notifier.serialize(2)

        return local.objectNotFound response unless searialized[type]?
        object = searialized[type]
        path   = try deeper.split '/'

        recurse request, object, path, {}, (error, result) ->
        
            response.writeHead statusCode

            if deeper? 

                #
                # additional path has been passed in,
                # only return the object at that location
                #

                deeper.split('/').map (key) -> result = result[key]

            response.write JSON.stringify result, null, 2
            response.end()


recurse = (request, object, path, result, callback) -> 

    try next = path.shift()
    for key of object

        #
        # * this for loop automatically listifies viq the recursion in when 'object'
        # * use case is for array of acucmulating errors / warnings to be viewable
        #   over the api, later deletable / resettable, the most sensible approach
        #   to this is not yet clear, the resuest ovject is bein passed in here 
        #   as likely to be used for /..?..&... activities on the url path
        # 
        #  

        if next? then continue unless key is next

        switch typeof object[key]

            when 'object'
                
                result[key] = {}
                recurse request, object[key], path, result[key]

            when 'number', 'string'

                result[key] = object[key]

            when 'function'

                #
                # only list functions with nested $$notice property
                #

                result[key] = {} if object[key].$$notice?


    callback null, result if typeof callback is 'function'

