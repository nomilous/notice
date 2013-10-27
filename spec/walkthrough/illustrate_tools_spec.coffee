{hub}  = require '../../lib/notice'
client = require('./api_client') API_PORT = 3333
ipso   = require 'ipso'


class ExampleTool
    constructor: ->
        @function = (opts, callback) ->

            callback null, with: some: thing: gotten: from: 'else where'

        @function.$$notice = {}


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

                return done() unless err?
                throw err



    it 'starts the above hub and runs this following demo chain', ipso (facto) -> 

        #@timeout(20000)

        @hub.use 

            title: 'Middleware Title'
            (next, capsule, traversal) -> 

                # console.log capsule
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
        # POST new middleware onto the "tail" of the pipeline
        #

        .then client.post

            path: '/hubs/1/middlewares'
            customMedia1: 
                
                title: 'use tool'
                fn: (next, capsule, traversal) -> 

                    console.log capsule.$$tick # HUH?
                    next()



        .then ({statusCode, body}) -> 

            console.log """

            inserted new middleware - details:
            ----------------------------------

            """, body





        #facto()
        



