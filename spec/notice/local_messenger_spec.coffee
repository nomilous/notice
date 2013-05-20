require('nez').realize 'LocalMessenger', (localMessenger, test, it, should) -> 

    it 'loads local messenger module from $HOME/.notice/messenger', (done) -> 

        home = process.env.HOME
        process.env.HOME = '../../'
        messenger = localMessenger()
        process.env.HOME = home
        messenger.should.equal 'FAKE TEST MESSENGER'
        test done
