notice = require '../../../lib/notice'
{readdirSync,lstatSync,readFileSync} = require 'fs'
{compile} = require 'coffee-script'
{sep} = require 'path'
{all} = require 'when'
WAIT_FOR_COMPILE = 1000


console.log grace: WAIT_FOR_COMPILE
setTimeout ( -> 

    #
    # quick hac - validation exercise 
    # verify hub as suitable core for realize
    # https://github.com/nomilous/realize/tree/develop
    # for the first use case (specs)
    #

    
    Hub = notice.hub 

        api: 
            listen: port: 8888
            authenticate: username: 'user', password: ''

        root: routes = 

            load: (opts, callback) -> 

                #
                # initialize the spec tree
                # ------------------------
                # 
                # curl -u user: :8888/load
                # 

                result   = {}
                nodes    = []
                promises = []
                recurse  = (base, result, files) -> 

                    for file in files

                        path = base + sep + file
                        stat = lstatSync path

                        if stat.isDirectory()

                            nodes.push file
                            result[file] = {}
                            recurse path, result[file], readdirSync path
                            nodes.pop()
                            continue

                        try if name = file.match(/(.*)_spec\.coffee/)[1]

                            nodes.push name
                            script   = readFileSync( path ).toString()
                            js       = compile script, bare: true
                            spec     = {}
                            place    = spec

                            #
                            # define functions used in the "specs"
                            # ------------------------------------
                            # 

                            describe = context = (descr, fn) -> 

                                if fn?

                                    nodes.push descr
                                    b4    = place
                                    place = place[descr] = {}

                                    #
                                    #   How
                                    #   ===
                                    # 
                                    # * create a hub (middleware pipeline) for each
                                    #   vertex (describe/context section) in the 
                                    #   spec tree
                                    # 
                                    # * each middleware in each pipeline is either 
                                    #   an it() or emit() into the "nested" middleware
                                    #   pipeline that houses a subcontext.
                                    # 
                                    # * the result is a capsule pathway that recurses
                                    #   the hub "tree"
                                    # 
                                    # * a capsule (as container for the accumulating 
                                    #   results) is inserted (via API) into the root
                                    #   hub.
                                    # 
                                    # * the accumulated test results are returned to
                                    #   waiting http client
                                    # 
                                    #   OUTSTANDINGs for this to work
                                    #   -----------------------------
                                    # 
                              # TODO: * ignore rejection  - currently the first test 
                                    #   failure will result in the capsule falling 
                                    #   to the origin emitter as a rejection.
                                    # 
                              # TODO: * boomerang - currently the emit calls back at 
                                    #   ACK from the remote hub and not after the remote 
                                    #   traversal, the returned capsule will not yet 
                                    #   have entered the nested contexts.
                                    #   
                             # LATER  * promise notifier (back channel for per test 
                                    #   results as they occur send back to the waiting 
                                    #   http requestor)
                                    # 
                             # LATER  * hooks (before and after) need a construct of 
                                    #   some kind
                                    # 

                                    promises.push Hub.create 

                                        title: nodes.join '/'
                                        
                                        -> # fn() if fn?


                                    place = b4
                                    nodes.pop()

                                else place[descr] = 'pending'


                            it = (test, fn) ->

                                nodes.push test
                                console.log nodes
                                nodes.pop()

                            
                            #
                            # "load" the "spec"
                            # -----------------
                            #

                            result[name] = eval js

                            nodes.pop()


                #path = __dirname + '/../../../spec'
                path = __dirname + '/spec'
                recurse path, result, readdirSync path

                all( promises ).then(

                    -> callback null, result
                    (error) -> callback error

                )

                

                


        routes.load.$notice = {}


), WAIT_FOR_COMPILE