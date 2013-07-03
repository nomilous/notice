require('nez').realize 'Local', (Local, test, context, should, fs, Notice) -> 

    clearCache = -> 
        
        #
        # clear the already required 'local' from the require cache 
        #

        delete require.cache[process.env.HOME + '/.notice/middleware.js']



    context 'local.all', (it) -> 

        it 'contains definition of the local middleware to be assigned to all pipelines', (done) -> 

            clearCache()
            spy = fs.readFileSync
            fs.readFileSync = (file) -> 
                fs.readFileSync = spy
                return """
                module.exports = {
                    all: function( msg, next ) {
                        msg.append_a_property = 'value'
                        next();
                    }
                }
                """

            Local().all.toString().should.match /msg.append_a_property = 'value'/
            test done


    # 
    # context 'local.*', (it) -> 

    #     it 'returns defaults the match spec and middleware fn per origin name', (done) ->

    #         clearCache()
    #         spy = fs.readFileSync
    #         fs.readFileSync = (file) -> 
    #             fs.readFileSync = spy
    #             return """

    #             module.exports = {
    #                 originName: function( msg, next ) {
    #                     //moo
    #                     next();
    #                 }
    #             }
    #             """

    #         Local().originName.matchAll.should.eql origin: 'originName'
    #         Local().originName.fn.should.match /moo/
    #         test done


    #     it 'returns middlewares per origin name if array is defined', (done) ->

    #         clearCache()
    #         spy = fs.readFileSync
    #         fs.readFileSync = (file) -> 
    #             fs.readFileSync = spy
    #             return """

    #             module.exports = {

    #                 originName: [{ 
    #                         matchAll: {
    #                             type: 'event',
    #                             tenor: 'good'
    #                         },
    #                         fn: function( msg, next ) { 
    #                             //handle good
    #                             next();
    #                         }

    #                     },{
    #                         matchAll: {
    #                             type: 'event',
    #                             tenor: 'bad'
    #                         },
    #                         fn: function( msg, next ) { 
    #                             //handle bad
    #                             next();
    #                         }
    #                     }
    #                 ]
    #             }
    #             """

    #         Local().originName[0].fn.toString().should.match /handle good/
    #         Local().originName[0].matchAll.should.eql type: 'event', tenor: 'good'

    #         Local().originName[1].fn.toString().should.match /handle bad/
    #         Local().originName[1].matchAll.should.eql type: 'event', tenor: 'bad'
    #         test done
    # 
    # 
    # no, not yet... (rabbit hole!)


    context 'integrations', (it) -> 

        it 'loads local environment middleware from $HOME/.notice/middleware.js', (done) -> 

            clearCache()
            spy = fs.readFileSync
            fs.readFileSync = (file) -> 
                fs.readFileSync = spy
                file.should.equal process.env.HOME + '/.notice/middleware.js'
                test done

            notice = Notice.create( 'origin' )


        it 'allows definition of middleware that runs for all origins', (done) -> 

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


        it 'allows middleware that runs only for specific origins', (done) -> 

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


        it 'runs after all other middleware', (done) -> 

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

            notice  = Notice.create( 'origin name' )
            DEFINED = []

            notice.use (msg, next) -> 

                DEFINED['in middleware'] = property: msg.property
                next()


            notice.info('test1').then (msg) -> 

                DEFINED['in final message'] = property: msg.property


            setTimeout (->

                should.not.exist DEFINED['in middleware'].property
                DEFINED['in final message'].property.should.equal 'value'
                test done

            ), 10




