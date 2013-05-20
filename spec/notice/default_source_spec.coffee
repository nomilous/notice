require('nez').realize 'DefaultSource', (defaultSource, test, it, should) -> 

    it 'returns the parent module', (done) -> 

        defaultSource().should.equal 'default'
        test done

