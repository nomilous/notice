require('nez').realize 'Config', (Config, test, context, path) -> 

    context 'defaults', (it) -> 

        it 'loads .notice/handler from users home if handler is unspecified', (done) -> 

            home = process.env.HOME
            process.env.HOME = '../spec'
            Config()
            process.env.HOME = home
            Config.handler.toString().should.match /variable \= 'value'/
            test done

        it 'loads a default handler if no handler at $HOME/.notice/handler', (done) -> 

            #
            # force a module reload
            #

            delete require.cache[  path.join __dirname, '../lib/config.js'  ]
            delete require.cache[  path.join __dirname, '../lib/default_handler.js'  ]

            home = process.env.HOME
            process.env.HOME = '/fake/home'
            Config()
            process.env.HOME = home
            Config.handler.toString().should.match /default notification handler/
            test done


        it 'assignes the hander as provided', (done) -> 

            Config handler: -> test = 'configured handler'
            Config.handler.toString().should.match /configured handler/
            test done

