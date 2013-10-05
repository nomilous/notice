io = require 'socket.io'  # <---------------- weird name, cannot inject

# require('nez').realize 'Listen', (Listen, test, context, should, http, https, fs) -> 

Listener = require '../../../lib/notice/hub/listener'
should   = require 'should'
http     = require 'http'
https    = require 'https'
fs       = require 'fs'

describe 'Listen', ->

    context 'http', ->

        it 'starts an http server with default config', (done) -> 

            spy = http.createServer
            http.createServer = -> 
                http.createServer = spy
                return on: -> 
                    # stop socket.io
                    throw 'OKGOOD'


            try Listener.listen()
            catch error
                error.should.match /OKGOOD/
                done()

        it 'uses the supplied server', (done) -> 

            spy = http.createServer
            http.createServer = -> 
                http.createServer = spy
                throw new Error 'SHOULD NOT START'

            try Listener.listen server: on: -> throw 'OKGOOD'
            catch error
                error.should.match /OKGOOD/
                done()
            


    context 'https', -> 

        it 'starts an https server if cert and key are supplied', (done) -> 

            fs.readFileSync = -> return ''

            spy = https.createServer
            https.createServer = -> 
                https.createServer = spy
                return {
                    listen: -> 
                    on: -> throw 'OKGOOD'
                }

            try Listener.listen 
                cert: '/cert/file'
                key:  '/key/file'
            catch error
                error.should.match /OKGOOD/
                done()


    context 'socket.io', -> 

        it 'listens', (done) -> 

            spy = io.listen
            io.listen = -> 
                io.listen = spy
                throw 'OKGOOD'

            try Listener.listen server: {}
            catch error
                error.should.match /OKGOOD/
                done()

        it 'returns the listening socketio', (done) -> 

            listeningio = configure: ->

            spy = io.listen
            io.listen = -> 
                io.listen = spy
                return listeningio
                
            Listener.listen( server: {} ).should.equal listeningio
            done()

