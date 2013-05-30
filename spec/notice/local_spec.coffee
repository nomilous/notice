require('nez').realize 'LocalMessenger', (localMessenger, test, it, should) -> 

    it 'loads local messenger module for "Test Source 1" from $HOME/.notice/messenger', (done) -> 

        home = process.env.HOME
        process.env.HOME = '../../'

        source    = 'Test Source 1'
        messenger = localMessenger.find( source )
        process.env.HOME = home

        messenger.should.be.an.instanceof Function
        test done

    it 'returns null if no local messenger for the given source', (done) -> 

        home = process.env.HOME
        process.env.HOME = '../../'

        source    = 'Test Source 2'
        messenger = localMessenger.find( source )
        process.env.HOME = home

        should.not.exist messenger
        test done

    it 'returns null if no local messengers at all', (done) -> 

        home = process.env.HOME
        process.env.HOME = '/moon'
        
        source = 'teleporter'
        messenger = localMessenger.find( source )
        process.env.HOME = home

        should.not.exist messenger
        test done



