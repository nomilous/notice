should     = require 'should'
{recursor} = require '../../lib/management/recursor' 

describe 'recursor', -> 

    it 'responds method not allowed unless GET', (done) -> 

        instance = recursor
            methodNotAllowed: -> done()

        instance [], method: 'POST'


    it 'responds object not found id no hub at uuid', (done) -> 

        instance = recursor
            objectNotFound: -> done()
            hubContext: uuids: {}

        instance ['UUID'], method: 'GET'
