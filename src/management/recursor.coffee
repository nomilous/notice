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

        recurse request, object, [], {}, (error, result) ->
        
            response.writeHead statusCode
            response.write JSON.stringify result, null, 2
            response.end()


recurse = (request, object, path, result, callback) -> 

    for key of object

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

