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
                            # * a sort of push() pop() recursor
                            # 

                            describe = context = (descr, fn) -> 

                                if fn?

                                    nodes.push descr
                                    b4    = place
                                    place = place[descr] = {}

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
                            # "load" the "specs"
                            # ------------------
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