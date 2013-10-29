notice = require '../../../lib/notice'
{readdirSync,lstatSync} = require 'fs'
{sep} = require 'path'
WAIT_FOR_COMPILE = 1000


console.log grace: WAIT_FOR_COMPILE
setTimeout ( -> 

    
    Hub = notice.hub 

        api: 
            listen: port: 8888
            authenticate: username: 'user', password: ''

        root: routes = 

            specs: 

                #
                # url -u user: :8888/specs/list
                # 
                # {
                #   "dir": {
                #     "also_spec.coffee": {},
                #     "another_thing_spec.coffee": {}
                #   },
                #   "some_thing_spec.coffee": {}
                # }
                #

                list: (opts, callback) -> 

                    result  = {}
                    recurse = (base, result, files) -> 

                        for file in files

                            result[file] = {}
                            path = base + sep + file
                            stat = lstatSync path

                            if stat.isDirectory()
                                recurse path, result[file], readdirSync path
                                continue

                    path = __dirname + '/spec'
                    recurse path, result, readdirSync path

                    callback null, result

                    


        routes.specs.list.$notice = {}


), WAIT_FOR_COMPILE