should          = require 'should'
{authenticator} = require '../../lib/management/authenticator'

describe 'authenticator', -> 

    beforeEach -> 


        @headers = authorization: new Buffer('username:password', 'utf8').toString 'base64'
        @mockRequest = {}
        Object.defineProperty @mockRequest, 'headers', 
            get: => @headers


        @writeHead = ->
        @mockResponse = end: ->
        Object.defineProperty @mockResponse, 'writeHead', 
            get: => => @writeHead.apply null, arguments


    it 'decorates an http request handler', (done) -> 

        authenticate = authenticator 
            manager: 
                authenticate: -> 

        decoratedHandler = authenticate (req, res) -> 

            #
            # actual handler is only called if authentic
            #

            throw 'should not run'

        @headers = {}
        decoratedHandler @mockRequest, @mockResponse
        done()


    it 'responds with 401 if no auth provided', (done) -> 

        authenticate = authenticator 
            manager: 
                authenticate: -> 

        @headers = {}
        @writeHead = (statusCode, headers) ->

            statusCode.should.equal 401
            headers.should.eql 'www-authenticate': 'BASIC'
            done()


        authenticate(-> 

            throw 'should not run actual handler'

        ) @mockRequest, @mockResponse


    it 'uses configured upstream authorization call', (done) -> 

        authenticate = authenticator 
            manager: 
                authenticate: (username, password, callback) -> 
                    username.should.equal 'username'
                    password.should.equal 'password'
                    callback null, true
                    

        authenticate( (request, response) ->

            #
            # authentic, runs this (the actual)
            #

            done()

        ) @mockRequest, @mockResponse


    it 'does not call the request handler if not authentic', (done) -> 

        authenticate = authenticator 
            manager: 
                authenticate: (username, password, callback) -> 
                    callback null, false

        authenticate( (request, response) ->

            throw 'should not run'

        ) @mockRequest, @mockResponse
        
        setTimeout done, 10


    it 'uses configured "hard"coded username and password', (done) -> 

        authenticate = authenticator 
            manager: 
                authenticate:
                    username: 'username'
                    password: 'password'


        authenticate( (request, response) ->

            done()

        ) @mockRequest, @mockResponse



    it 'does not call the request handler if non matching from config', (done) -> 

        @headers = authorization: new Buffer('username:wrongpassword', 'utf8').toString 'base64'
        authenticate = authenticator 
            manager: 
                authenticate:
                    username: 'username'
                    password: 'password'


        authenticate( (request, response) ->

            throw 'should not run'

        ) @mockRequest, @mockResponse
        setTimeout done, 10

