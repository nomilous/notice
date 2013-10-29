notice = require '../../../lib/notice'
querystring = require 'querystring'

WAIT_FOR_COMPILE = 1000
console.log grace: WAIT_FOR_COMPILE
setTimeout (-> 

    Hub = notice.hub

        api: 

            listen: port: 8888
            authenticate: (username, password, callback) ->

                #
                # no native session capacity
                # --------------------------
                # 
                # * each hit at localhost:8888 makes this call
                #

                callback null, 
                    username: username
                    roles: groups: otherThings: whatever: 'this is async'

        root: routes = 

            tree:

                users: (opts, callback) -> 

                    #
                    # curl -u user: :8888/tree/users
                    #

                    callback null, [

                        { name: 'The Angry Pixie'  ,type: 'admin' }
                        { name: 'Silky the Fairy'  ,type: 'admin' }
                        { name: 'Mr.Watzisname'    ,type: 'admin' }
                        { name: 'Dame Washalot'    ,type: 'admin' }
                        { name: 'Moonface'         ,type: 'admin' }
                        { name: 'The Saucepan Man' ,type: 'admin' }
                        { name: 'Dame Slap'        ,type: 'admin' }

                        { name: 'Jo'               ,type: 'guest' }
                        { name: 'Bessie'           ,type: 'guest' }
                        { name: 'Fanny'            ,type: 'guest' }

                    ]

            core:

                hub:

                    create: (opts, callback) -> 

                        #
                        # Create a new hub at the API 
                        # ---------------------------
                        # 
                        # curl -u user: ':8888/core/hub/create?title=New%20Hub%20Title&uuid=Tx&port=3001'
                        #
                        ###

                          Upsert middleware into new hub
                          ------------------------------

                          curl -u user: -H 'Content-Type: text/coffeescript' :8888/hubs/Tx/middlewares/1 -d '  
                          title: "handler"
                          fn: (next, capsule, traversal) ->   
                              #
                              # inbound capsule containing module::function to run
                              #  
                              return next() unless capsule.require? and capsule.function?
                              capsule.result = require(capsule.require)[capsule.function]()
                              next() '



                        ###
                        #
                        #
                        #

                        config = querystring.parse opts.query
                        newHub = undefined

                        try

                            opts.root.hubContext.create

                                title:  config.title || 'DEFAULT HUB NAME'
                                uuid:   config.uuid
                                listen: port: config.port

                                tools: tools = 

                                    inject: (opts, callback) -> 

                                        #
                                        # new hub exposes tool at /hubs/:uuid:/tools/inject
                                        # -------------------------------------------------
                                        # 
                                        # it emits the inbound url query=string as a capsule
                                        # where the upserted middleware is waiting.
                                        #

                                        newHub.event( querystring.parse opts.query )
                                        .then (capsule) -> callback null, capsule

                                        # 
                                        # curl -u user: ':8888/hubs/Tx/tools/inject?require=os&function=loadavg'
                                        # 
                                        #     {
                                        #       "require": "os",
                                        #       "function": "loadavg",
                                        #       "result": [
                                        #         0.62255859375,
                                        #         0.71533203125,
                                        #         0.71533203125
                                        #       ]
                                        #     }
                                        # 
                                        #    http://nodejs.org/api/os.html  
                                        # 


                                (err, hub) -> 

                                    if err? then return callback err
                                    newHub = hub               # hoist the new hub for use in tools.inject
                                    tools.inject.$notice = {}  # mark tool as $notice(able) for api recursor
                                    callback null, hub



                                    



        routes.tree.users.$notice = {}
        routes.core.hub.create.$notice = {}




), WAIT_FOR_COMPILE



