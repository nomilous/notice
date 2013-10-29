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
                # {
                #   "dir": {
                #     "also": {
                #       "subject": "Also"
                #     },
                #     "another_thing": {
                #       "subject": "AnotherThing"
                #     }
                #   },
                #   "some_thing": {
                #     "subject": "SomeThing"
                #   }
                # }
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

                                describe = (subject) -> subject: subject

                                result[name] = eval js
                                
                                
                            

                    path = __dirname + '/../../../spec'
                    path = __dirname + '/spec'
                    recurse path, result, readdirSync path
                    callback null, result

                    


        routes.specs.list.$notice = {}


), WAIT_FOR_COMPILE