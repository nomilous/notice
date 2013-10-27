{hub}    = require '../../lib/notice'
{Client} = require 'dinkum'
ipso     = require 'ipso'


describe 'tools api', -> 

    before (done) -> 

        HubDefinition = hub

            api: 
                listen: port: 3333
                authenticate: (user, pass, callback) ->

                    #
                    # insert async auth step here
                    #

                    callback null, 
                        username: user
                        roles: ['pretend']

            ticks: 
                noop:
                    interval: 1

        @hubInstance = HubDefinition.create

            title: 'Hub Title'
            uuid:  1
            listen: port: 4444

            (err, hub) -> 

                return done() unless err?
                throw err



    it ''
