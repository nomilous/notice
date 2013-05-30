require('nez').realize 'Validate', (Validate, test, context, should) -> 

    context 'middleware( fn )', (it) ->

        it 'returns false if fn is invalid middleware', (done) ->

            Validate.middleware(   ->                     ).should.equal false
            Validate.middleware(   (msg) ->               ).should.equal false
            Validate.middleware(   (msg, next) ->         ).should.equal false
            Validate.middleware(   (msg, next) -> next    ).should.equal false
            test done


        it 'returns true if fn is valid middleware', (done) -> 

            Validate.middleware(   (msg, next) -> next()   ).should.equal true
            test done

