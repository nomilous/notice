require('nez').realize 'Configure', (Configure, test, context, path, Notice, Notify) -> 

    context 'notification source', (it) -> 

        it 'can be configured', (done) -> 

            Configure 
                source: 'name'
                messenger: (notification) -> 
                    notification.source.should.equal 'name'
                    test done

            Notice 'message'


        it 'defaults to the calling module', (done) -> 

            Configure
                messenger: (notification) -> 
                    notification.source.should.not.equal 'the calling module'
                    test done

            Notice 'message'











    # context 'defaults', (it) -> 

    #     it 'loads .notice/handler from users home if handler is unspecified', (done) -> 

    #         home = process.env.HOME
    #         process.env.HOME = '../spec'
    #         Configure()
    #         process.env.HOME = home
    #         Configure.handler.toString().should.match /variable \= 'value'/
    #         test done

    #     it 'loads a default handler if no handler at $HOME/.notice/handler', (done) -> 

    #         #
    #         # force a module reload
    #         #

    #         delete require.cache[  path.join __dirname, '../lib/config.js'  ]
    #         delete require.cache[  path.join __dirname, '../lib/default_handler.js'  ]

    #         home = process.env.HOME
    #         process.env.HOME = '/fake/home'
    #         Configure()
    #         process.env.HOME = home
    #         Configure.handler.toString().should.match /default notification handler/
    #         test done


    #     it 'assignes the hander as provided', (done) -> 

    #         Configure handler: -> test = 'configured handler'
    #         Configure.handler.toString().should.match /configured handler/
    #         test done
