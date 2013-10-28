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

        root: 

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





), WAIT_FOR_COMPILE
