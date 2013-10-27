{hub}  = require '../../../lib/notice'
client = require('../api_client') API_PORT = 3333
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
        # * a function that is tagged as $$notice(able)
        #

        @function = (opts, callback) ->

            # 
            # console.log FUNCTION_OPTS: opts
            # 

            callback null, with: some: thing: gotten: from: 'else where'

        @function.$$notice = {}


        #
        # * this one is tagged invisibly
        #

        # @['stats()'] = (opts, callback) -> 
        @stats = (opts, callback) -> 
            setTimeout (->
                callback null, count: privateCounter
            ), 100

        # Object.defineProperty @['stats()'], '$$notice', 
        Object.defineProperty @stats, '$$notice', 
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

        HubDefinition = hub

            api: 
                listen: port: API_PORT
                authenticate: (user, pass, callback) ->
                    #
                    # insert async auth step here
                    #
                    callback null, 
                        username: user
                        roles: ['pretend']

            ticks: 
                onYourMarks:
                    interval: 1 # quite high frequency

        instance = HubDefinition.create

            title: 'Hub Title'
            uuid:  1
            listen: port: 4444

            tools:
                #
                # assign an instance of example tool 
                #
                example: new ExampleTool

            (err, @hub) => 

                throw err if err?
                setInterval (=> @hub.event 'test' ), 100
                done()



    it 'starts the above hub and runs this following demo chain', ipso (facto) -> 

        @timeout(20000)

        @hub.use 

            title: 'Middleware Title'
            (next, capsule, traversal) -> 

                #console.log capsule.$$all

                capsule.$$set
                    key: 'value'
                    hidden: true 
                next()


        client.get 

            path: '/hub/1/tools/example'

        .then ({body}) -> 

            console.log """.

            api exposes tools 
            -----------------

            """, body


        .then client.get 

            path: '/hub/1/tools/example/function'

        .then ({statusCode, body}) -> 

            console.log """

            api provides access to the funcion callback results
            ---------------------------------------------------

            """, body

        .then client.get

            path: '/hub/1/tools/example/function/with/some/thing/gotten'

        .then ({statusCode, body}) -> 

            console.log """

            the results can be drilled into
            -------------------------------

            """, body

        
        # 
        # POST new middleware into the remote hub's pipeline
        #

        .then client.post

            path: '/hubs/1/middlewares'
            customMedia1: 
                
                title: 'use tool'
                fn: (next, capsule, traversal) -> 

                    #
                    # * this new middleware increments the 
                    #   counter in the example tool
                    #

                    eg = traversal.tools.example
                    eg.increment()

                    # console.log capsule.$$all # oh dear... (nothing!)
                    next()


        .then ({statusCode, body}) -> 

            console.log """

            inserted new middleware - details:
            ----------------------------------

            """, body


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
            ----------------------------------

            """, body


            facto()     # COMMENT THIS - to make the api available for 20 seconds for this:
                        # 
                        # 
                        #    curl -u user:pass localhost:3333/hubs/1/tools/example/stats
                        # 
                        # 


