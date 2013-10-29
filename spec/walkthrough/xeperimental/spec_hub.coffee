notice = require '../../../lib/notice'
{readdirSync,lstatSync,readFileSync} = require 'fs'
{compile} = require 'coffee-script'
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
                # curl -u user: :8888/specs/list
                # 

                list: (opts, callback) -> 

                    result  = {}
                    recurse = (base, result, files) -> 

                        for file in files

                            path = base + sep + file
                            stat = lstatSync path

                            if stat.isDirectory()
                                result[file] = {}
                                recurse path, result[file], readdirSync path
                                continue

                            try if name = file.match(/(.*)_spec\.coffee/)[1]

                                script = readFileSync( path ).toString()
                                js     = compile script, bare: true

                                spec     = {}
                                place    = spec
                                describe = (subject, test) -> 

                                    b4             = place
                                    place = place[subject] = {}
                                    test()
                                    place = b4

                                context  = (descrip) -> 

                                    console.log context: descrip
                                    place[descrip] = {}

                                eval js
                                result[name] = spec

                                # {
                                #   "dir": {
                                #     "also": {
                                #       "Also": {
                                #         "when first": {},
                                #         "when in the middle": {},
                                #         "when last": {}
                                #       }
                                #     },
                                #     "another_thing": {
                                #       "AnotherThing": {}
                                #     }
                                #   },
                                #   "some_thing": {
                                #     "SomeThing": {}
                                #   }
                                # }

                                # curl -u user: :8888/specs/list/dir/also/Also
                                # 
                                #  {
                                #    "when first": {},
                                #    "when in the middle": {},
                                #    "when last": {}
                                #  }


                            

                    # path = __dirname + '/../../../spec'
                    path = __dirname + '/spec'
                    recurse path, result, readdirSync path
                    callback null, result

                    


        routes.specs.list.$notice = {}


), WAIT_FOR_COMPILE