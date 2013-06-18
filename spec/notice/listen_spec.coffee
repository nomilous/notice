require('nez').realize 'Listen', (Listen, test, context, should, http, https, fs) -> 

    context 'http', (it) ->

        it 'starts an http server with default config', (done) -> 

            spy = http.createServer
            http.createServer = -> 
                http.createServer = spy

                return listen: (port, iface) ->  
                    port.should.equal   10001
                    iface.should.equal 'localhost'
                    test done

            Listen()

        it 'uses the supplied server', (done) -> 

            spy = http.createServer
            http.createServer = -> 
                http.createServer = spy
                throw new Error 'SHOULD NOT START'

            Listen server: {}
            test done


    context 'https', (it) -> 

        it 'starts an https server if cert and key are supplied', (done) -> 

            fs.readFileSync = -> return ''

            spy = https.createServer
            https.createServer = -> 
                https.createServer = spy

                return listen: -> test done

            Listen 
                cert: '/cert/file'
                key:  '/key/file'



