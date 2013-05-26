require('nez').realize 'Configure', (Configure, test, context, path, Notice, Notify) -> 

    context 'notification source', (it) -> 

        it 'is mandatory', (done) -> 

            try 
                Configure()

            catch error
                error.should.match /requires opts\.source/
                test done

        it 'require a callback to receive the configured notifier', (done) -> 

            try 
                Configure source: 'TEST'
            
            catch error
                error.should.match /requires callback to receive configured notifier/
                test done


        it 'can be configured', (done) -> 

            Configure(
                source: 'name'
                messenger: (notification) -> 
                    notification.source.ref.should.equal 'name'
                    test done
                    
                (error, notifier) -> 
            )

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

