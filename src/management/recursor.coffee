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

    request.$$root     ||= result  # keep original root for termination case beyond async call
    request.$$callback ||= callback

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
                recurse request, object[key], path, result[key]  # huh?? , callback

            when 'number', 'string'

                result[key] = object[key]

            when 'function'

                #
                # * only list functions with nested $$notice property
                # * these come up in the api tree as {}
                # * indestinguishable from properties (for now)
                # 

                if object[key].$$notice?

                    unless next?
                        result[key] = {} 
                        continue

                    #
                    # run the function if the 'deeper' path was provided 
                    # 
                    # ie. lazyloadable has been activated by directly 
                    #     calling a path through a $$notice function
                    #

                    request.$$walking = true
                    return object[key] {opts: '##undecided1'}, (error, nested) -> 

                        result[key] = nested
                        request.$$callback null, request.$$root if typeof request.$$callback is 'function' # and path.length == 0

    #
    # flat case termination, no async lazyload
    #
    
    callback null, result if not request.$$walking? and typeof callback is 'function'

