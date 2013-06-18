require('nez').realize 'Hub', (Hub, test, context) -> 

    context 'create()', (it) -> 

        it 'is an exported function', (done) -> 

            Hub.create.should.be.an.instanceof Function
            test done


