http    = require 'http'
https   = require 'https'
should  = require 'should'
{manager,_manager} = require '../../lib/management/manager'


describe 'manage', ->

    beforeEach -> 
        @createHttp = http.createServer
        @createHttps = https.createServer

    afterEach -> 
        http.createServer = @createHttp
        https.createServer = @createHttps


    it 'throws on missing config.manage.listen', (done) -> 

        try manager {}
        catch error
            done()

    it 'throws on missing port', (done) -> 

        try manager manager: listen: {}, authenticate: {}
        catch error
            error.should.match /manager requires opt config.manager.listen.port/
            done()

    it 'creates an http server', (done) -> 

        http.createServer = -> done(); listen: ->
        manager manager: 
            authenticate: {}
            listen: port: 3210


    xit 'creates an https server if cert and key are configured', (done) -> 

        # 
        # dunnot why this isnt stubbing
        # 

        https.createServer = -> done(); listen: ->
        manager manager: 
            authenticate: {}
            listen:
                port: 3210
                cert: 'cert'
                key:  'key'
