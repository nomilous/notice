require('nez').realize 'Local', (Local, test, context, should, fs, Notice) -> 

    clearCache = -> delete require.cache[process.env.HOME + '/.notice/middleware.js']

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
                test done

            notice1  = Notice.create( 'origin one' )
            notice2  = Notice.create( 'origin two' )
            RECEIVED = []

            notice1.info('test1').then (msg) -> RECEIVED.push msg
            notice1.info('test2').then (msg) -> RECEIVED.push msg

            setTimeout (->

                RECEIVED[0].property.should.equal 'value'
                RECEIVED[1].property.should.equal 'value'
                test done

            ), 10

