notice = require '../../../lib/notice'

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

            core: new class

                constructor: -> 

                    ( @function = (opts, callback) -> 

                            callback null, 
                                tree: 
                                    of: 'stuff' ).$notice = {}

                            #
                            # curl -u user: :8888/core/function/tree
                            #  
                            #  {
                            #    "of": "stuff"
                            #  }
                            #

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




        routes.tree.users.$notice = {}



), WAIT_FOR_COMPILE
