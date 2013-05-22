require('nez').realize 'DefaultMessenger', (DefaultMessenger, test, it, Notice) -> 

    it 'becomes the messenger if none is defined', (done) -> 

        Notice.configure source: 'supplies'

        swap = console.log
        console.log = (msg) -> 
            console.log = swap
            
            msg.should.match /default messenger/
            test done

        Notice.event.normal 'dispatch', '15 cable trays'

