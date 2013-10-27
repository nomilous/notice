client = require('../api_client') API_PORT = 3333
HubDefinition = require('../hub_definition') API_PORT
ipso   = require 'ipso'

#
# NOTE: not letting the test run to its end results in the socket
#       used by the api to raise with EADDRINUSE
#

privateCounter = 0

class ExampleTool

    constructor: ->

        #
        # called remotely via notice REST api
        # -----------------------------------
        #
        # * a function that is tagged as $notice(able)
        #

        @function = (opts, callback) ->

            # 
            # console.log FUNCTION_OPTS: opts
            # 

            callback null, with: some: thing: gotten: from: 'else where'

        @function.$notice = {}


        #
        # * this one is tagged invisibly
        #

        # @['stats()'] = (opts, callback) -> 
        @stats = (opts, callback) -> 
            setTimeout (->
                callback null, count: privateCounter
            ), 100

        # Object.defineProperty @['stats()'], '$notice', 
        Object.defineProperty @stats, '$notice', 
            enumerable: false
            value: {}


        #
        # used in middleware
        # ------------------
        # 
        # * increment the counter (used in middleware)
        #

        @increment = -> privateCounter++


    other: stuff: 'too'




describe 'tools api', -> 

    before (done) -> 

        instance = HubDefinition.create

            title: 'Hub Title'
            uuid:  1
            listen: {} # port: 4444

            tools:
                #
                # assign an instance of example tool 
                #
                example: new ExampleTool

            (err, @hub) => 

                throw err if err?

                #
                # console.log HUB_LISTENING_AT: @hub.listening
                # setInterval (=> @hub.event 'test', data: 1 ), 100
                # 

                done()



    it 'starts the above hub and runs this following demo chain', ipso (facto) -> 

        @timeout(5000)

        @hub.use 

            title: 'Middleware Title'
            (next, capsule, traversal) -> 

                # 
                # capsule.$set
                #     key: 'value'
                #     hidden: true
                #     protected: true
                # 

                next()


        client.get 

            path: '/hubs/1/tools/example'

        .then ({body}) -> 

            console.log """.

            api exposes tools 
            =================
            curl -u user:pass localhost:3333/hubs/1/tools/example
            -----------------

            """, body


        .then client.get 

            path: '/hubs/1/tools/example/function'

        .then ({statusCode, body}) -> 

            console.log """

            api provides access to the funcion callback results
            ===================================================
            curl -u user:pass localhost:3333/hubs/1/tools/example/function
            ---------------------------------------------------

            """, body

        .then client.get

            path: '/hubs/1/tools/example/function/with/some/thing/gotten'

        .then ({statusCode, body}) -> 

            console.log """

            the results can be drilled into
            ===============================
            curl -u user:pass localhost:3333/hubs/1/tools/example/function/with/some/thing/gotten
            -------------------------------

            """, body

        
        # 
        # POST new middleware into the remote hub's pipeline
        #

        .then client.post

            path: '/hubs/1/middlewares'
            middleware: 
                
                title: 'use tool'
                fn: (next, capsule, traversal) -> 

                    #
                    # console.log capsule.$all
                    # console.log capsule.$uuid
                    # 

                    #
                    # * this new middleware increments the 
                    #   counter in the example tool
                    #

                    eg = traversal.tools.example
                    eg.increment()
                    next()

        .then ({statusCode, body}) -> 

            console.log """

            insert new middleware - details
            ===============================
            curl -u user:pass -H 'Content-Type: text/coffeescript' localhost:3333/hubs/1/middlewares --data '

            title: "new middleware"
            fn: (next, capsule) -> 
                console.log capsule
                next()

            '

            curl -u user:pass localhost:3333/hubs/1/middlewares/3/disable
            curl -u user:pass localhost:3333/hubs/1/middlewares/3/enable
            -------------------------------

            """, body

        #
        # .then client.get
        #     path: '/hubs/1/middlewares/2/fn'
        # .then ({statusCode, body}) -> 
        #     console.log NEW_MIDDLEWARE_FN: body
        #

        .then client.get 

            path: '/hubs/1/tools/example/stats'

                                            #
                                            # path: '/hubs/1/tools/example/stats()'
                                            # 
                                            # ##undecided4
                                            # 
                                            # * that worked...!
                                            # * hmmmmmmmmmmmmm! 
                                            # * thinks: /hubs/1/tools/example/stats( args )
                                            # * then thinks: /hubs/1/tools/example/stats( args, callback://... )
                                            # * hmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm! 
                                            # 

        .then ({statusCode, body}) -> 

            console.log """

            get result from the stats function
            ==================================
            curl -u user:pass localhost:3333/hubs/1/tools/example/stats
            ----------------------------------

            """, body

            console.log """

            comment # facto() # to make the test run for longer

            """
            
            facto()


