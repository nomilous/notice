{authenticator} = require '../../lib/management/authenticator'

describe 'authenticator', -> 

    it 'allows upstream authorization call', (done) -> 

        a = authenticator 
            manager: 
                authenticate: -> done()

        a()

