require('nez').realize 'Configure', (Configure, test, context, LocalMessenger, DefaultMessenger, NotifierFactory) -> 

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


        # it 'falls back to using a provided messenger', (done) -> 
        #     m = (msg) -> 
        #     NotifierFactory.prototype.create = (messenger, config) -> 
        #         messenger.should.equal m
        #         test done
        #     Configure { 
        #         source: 'TEST'
        #         messenger: m
        #     }, -> 


        # it 'falls back to using the default handler at last', (done) -> 
        #     NotifierFactory.prototype.create = (messenger, config) -> 
        #         messenger.should.eql DefaultMessenger
        #         test done
        #     Configure { 
        #         source: 'TEST'    
        #     }, -> 


    context 'callback', (it) -> 

        it 'provides the message generator', (done) -> 

            Configure { 

                source: 'TEST'
                messenger: (msg) -> test done

            }, (error, notify) -> 

                notify.info.normal 'test message'


