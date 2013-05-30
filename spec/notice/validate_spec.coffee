require('nez').realize 'Validate', (Validate, test, context) -> 

    context 'validMiddleware', (it) ->

        it 'ensures the provided function is valid middleware', (done) ->

            Validate.middleware( 

                -> 

            ).should.equal false


            test done
