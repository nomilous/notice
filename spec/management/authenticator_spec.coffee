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



    it 'responds with 401 if no auth provided', (done) -> 

        a = authenticator 
            manager: 
                authenticate: -> 

        @headers = {}
        @writeHead = (statusCode, headers) ->

            statusCode.should.equal 401
            headers.should.eql 'www-authenticate': 'BASIC'
            done()


        a @mockRequest, @mockResponse


    it 'uses configured upstream authorization call', (done) -> 

        a = authenticator 
            manager: 
                authenticate: -> done()

        a @mockRequest, @mockResponse
