require('nez').realize 'Local', (Local, test, context, should, fs, Notice) -> 

    clearCache = -> 
        
        #
        # clear the already required 'local' from the require cache 
        #

        delete require.cache[process.env.HOME + '/.notice/middleware.js']

    context 'loads environment middleware', (that) -> 

        that 'can be defined $HOME/.notice/middleware.js', (done) -> 

            clearCache()
            spy = fs.readFileSync
            fs.readFileSync = (file) -> 
                fs.readFileSync = spy
                file.should.equal process.env.HOME + '/.notice/middleware.js'
                test done

            notice = Notice.create( 'origin' )


        that 'allows definition of middleware that runs for all origins', (done) -> 

            clearCache()
            spy = fs.readFileSync
            fs.readFileSync = (file) -> 
                fs.readFileSync = spy
                return """

                module.exports = {

                    all: function( msg, next ) {

                        msg.property = 'value'
                        next();

                    }

                }
                """

            notice1  = Notice.create( 'origin one' )
            notice2  = Notice.create( 'origin two' )
            RECEIVED = {}

            notice1.info('test1').then (msg) -> RECEIVED[msg.context.origin] = msg
            notice2.info('test2').then (msg) -> RECEIVED[msg.context.origin] = msg

            setTimeout (->

                RECEIVED['origin one'].property.should.equal 'value'
                RECEIVED['origin two'].property.should.equal 'value'
                test done

            ), 10


        that 'allows middleware that runs only for specific origins', (done) -> 

            clearCache()
            spy = fs.readFileSync
            fs.readFileSync = (file) -> 
                fs.readFileSync = spy
                return """

                module.exports = {

                    'origin name': function(msg, next) {

                        msg.property = 'value'
                        next();

                    }

                }
                """

            notice1  = Notice.create( 'origin name' )
            notice2  = Notice.create( 'another origin name' )
            RECEIVED = {}

            notice1.info('test1').then (msg) -> RECEIVED[ msg.context.origin ] = msg
            notice2.info('test2').then (msg) -> RECEIVED[ msg.context.origin ] = msg

            setTimeout (->

                RECEIVED['origin name'].property.should.equal 'value'
                should.not.exist RECEIVED['another origin name'].property
                test done

            ), 10

        


