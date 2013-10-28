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
                        # curl -u user: ':8888/core/hub/create?title=New%20Hub%20Title&port=3001'
                        #

                        config = querystring.parse opts.query

                        try

                            opts.root.hubContext.create

                                title:  config.title || 'DEFAULT HUB NAME'
                                uuid:   config.uuid
                                listen: port: config.port

                                (err, hub) -> 

                                    if err? then return callback err
                                    callback null, hub

                       



        routes.tree.users.$notice = {}
        routes.core.hub.create.$notice = {}




), WAIT_FOR_COMPILE
