testable = undefined
module.exports._recursor = -> testable
module.exports.recursor  = (local, type) -> 

    testable = ([opts, uuid, deeper], request, response, statusCode = 200) -> 

        if type == 'tools' or type == 'root'

#            
#                    
#                        EXPERIMENTAL X EXPERIMENTAL X EXPERIMENTAL
#                        ==========================================
#
#                                 Open wide for API tools
#                                 -----------------------
#
#                                       TAKE NOTE!
#                                       ==========
#                    
#                          This exposes INTERNAL structures that
#                                         
#                                       **WILL**
#                               
#                              be changed without warning
#
#                  ...(ecau.e this fr...wo.k is stil und.. constru)....
#                    
#
#                    
#                    The **ENTIRE** api context is exposed at opts.root
#                    into $notice(able) FUNCTIONS nested into the tools 
#                    tree in of a running hub instance. 
#
#                         These FUNCTIONS are callable via the API 
#
#                                /hubs/:uuid:/tools/**/*
#                    
#                        
#
#                         The url path walker is currently only
#                        capable of traversing ONE callback tier.
#
#                                        i.e.
#
#            /hubs/:uuid:/tools/thing/FUNCTION1/callback-tree/more/FUNCTION2
#
#                                  is not accessable  
#
#
#

            

            opts.root = local



        else

            return local.methodNotAllowed response unless request.method == 'GET'

        if type == 'root'

            object = local.root

        else

            return local.objectNotFound response unless local.hubContext.hubs[uuid]

            notifier    = local.hubContext.hubs[uuid]
            searialized = notifier.serialize(2)

            return local.objectNotFound response unless searialized[type]?

            object = searialized[type]
            path   = try deeper.split '/'

        recurse opts, request, object, path, {}, (error, result) ->

            if deeper? 

                #
                # additional path has been passed in,
                # only return the object at that location
                #

                deeper.split('/').map (key) -> result = result[key]


            body = JSON.stringify result, null, 2

            response.writeHead statusCode,
                'Content-Type': 'application/json'
                'Content-Length': body.length

            response.write body
            response.end()


recurse = (opts, request, object, path, result, callback) -> 

    request.$root     ||= result  # keep original root for termination case beyond async call
    request.$callback ||= callback

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
                recurse opts, request, object[key], path, result[key]  # huh?? , callback

            when 'number', 'string'

                result[key] = object[key]

            when 'function'

                #
                # * only list functions with nested $notice property
                # * these come up in the api tree as {}
                # * indestinguishable from properties (for now)
                # 

                if object[key].$notice?

                    unless next?
                        result[key] = {} 
                        continue

                    #
                    # run the function if the 'deeper' path was provided 
                    # 
                    # ie. lazyloadable has been activated by directly 
                    #     calling a path through a $notice function
                    #

                    request.$walking = true
                    return object[key] opts, (error, nested) -> 

                        result[key] = nested

                        #
                        # stopping at one jump... (some impendiments on the nesteds)
                        # recurse request, object[key], path, result[key]
                        # 

                        request.$callback null, request.$root if typeof request.$callback is 'function' # and path.length == 0
                        


    #
    # flat case termination, no async lazyload
    #
    
    callback null, result if not request.$walking? and typeof callback is 'function'

