should     = require 'should'
{recursor} = require '../../lib/management/recursor' 

describe 'recursor', -> 

    it 'responds method not allowed unless GET', (done) -> 

        instance = recursor
            methodNotAllowed: -> done()

        instance [], method: 'POST'

