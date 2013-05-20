require('nez').realize 'Notice', (subject, test, it, should) -> 

    it 'exports config() function', (done) -> 

        subject.configure.should.be.an.instanceof Function
        test done

    # it 'exports a notify() function', (done) -> 

    #     subject.notify.should.be.an.instanceof Function
    #     test done

    #     