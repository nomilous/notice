should          = require 'should'
{authenticator} = require '../../lib/management/authenticator'

describe 'authenticator', -> 

    beforeEach -> 


        @headers = authorization: {}
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


        authenticate(->) @mockRequest, @mockResponse


    it 'uses configured upstream authorization call', (done) -> 

        authenticate = authenticator 
            manager: 
                authenticate: -> done()

        authenticate(->) @mockRequest, @mockResponse
