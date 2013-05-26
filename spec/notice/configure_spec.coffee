require('nez').realize 'Configure', (Configure, test, context, LocalMessenger, DefaultMessenger) -> 


    context 'expects a config hash as arg1', (it) -> 

        it 'is mandatory', (done) -> 

            try 
                Configure()

            catch error
                error.should.match /requires config\.source/
                test done


    context 'expects a callback as arg2', (it) -> 

        it 'is mandatory', (done) -> 

            try
                Configure source: 'TEST'

            catch error
                error.should.match /requires callback to receive configured notifier/
                test done



    context 'default configuration', (it) -> 


        it 'first attempts to locate a local messenger', (done) ->

            swap = LocalMessenger.find
            LocalMessenger.find = (source) -> 
                LocalMessenger.find = swap

                source.should.equal 'TEST'
                test done

            Configure { source: 'TEST' }, -> 


        it 'falls back to using a provided messenger', (done) -> 

            m = (msg) -> 

            Configure { 

                source: 'TEST'
                messenger: m

            }, -> 

            Configure.config.messenger.should.equal m
            test done


        it 'falls back to using the default handler at last', (done) -> 

            Configure { 

                source: 'TEST'    

            }, -> 

            Configure.config.messenger.should.equal DefaultMessenger
            test done
