require('nez').realize 'Notice', (Notice, test, it, should) -> 

    it 'is', (done) -> 

        console.log Notice.toString()

        test done

    