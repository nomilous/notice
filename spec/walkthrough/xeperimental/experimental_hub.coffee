notice = require '../../../lib/notice'

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
                    #
        # hubs: {}  # forbidden
                    #

        thing: {}

        #
        # curl -u user: :8888
        # {
        #   "thing": {}
        # }
        # 

