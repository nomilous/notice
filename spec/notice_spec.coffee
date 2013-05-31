require('nez').realize 'Notice', (Notice, test, it, should) -> 

    it 'is', (done) -> 

        notifier = Notice.create 'origin name'
        test done

    