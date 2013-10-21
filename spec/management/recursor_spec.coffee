should     = require 'should'
{recursor} = require '../../lib/management/recursor' 

describe 'recursor', -> 

    it 'responds method not allowed unless GET', (done) -> 

        instance = recursor
            methodNotAllowed: -> done()

        instance [], method: 'POST'


    it 'responds object not found id no notifier / hub at uuid', (done) -> 

        instance = recursor
            objectNotFound: -> done()
            hubContext: uuids: {}

        instance ['UUID'], { method: 'GET' }


    it 'serializes the notifier at level2', (done) -> 

        instance = recursor
            hubContext: 
                uuids: 
                    UUID: 
                        serialize: (level) -> 
                            level.should.equal 2
                            done()
                            throw 'go no further'

        try instance ['UUID'], { method: 'GET' }


    it 'responds object not found if searialization[type] does not exist', (done) -> 

        instance = recursor
            objectNotFound: -> done()
            hubContext: 
                uuids: 
                    UUID: 
                        serialize: (level) -> 
                            notType: test: 'value'

            'type'

        instance ['UUID'], { method: 'GET' }


    it 'responds with 200 and serializeation[type] as JSON string', (done) -> 

        instance = recursor
            hubContext: 
                uuids: 
                    UUID: 
                        serialize: (level) -> 
                            type: 
                                test: 'value'
                                deeper: 
                                    and: 'this'

            'type'

        STATUS = undefined
        RESULT = undefined
        instance ['UUID'], { method: 'GET' }, 

            writeHead: (statusCode) -> STATUS = statusCode
            write: (result) -> RESULT = result
            end: ->

                STATUS.should.equal 200
                JSON.parse( RESULT ).should.eql 
                    test: 'value'
                    deeper:             
                        and: 'this'
                done()


    it 'includes any functions marked with $$notice', (done) -> 

        fn = (opts, callback) -> 
        fn.$$notice = {}

        instance = recursor
            hubContext: 
                uuids: 
                    UUID: 
                        serialize: (level) -> 
                            type: 
                                test: 'value'
                                fn: fn
                                regularFn: ->
                                deeper:
                                    and:
                                        deeper: 
                                            fn: fn

            'type'

        instance ['UUID'], { method: 'GET' }, 
            end: ->
            writeHead: ->
            write: (result) -> 

                JSON.parse( result ).should.eql

                    test: 'value'
                    fn: {}
                    deeper:
                        and:
                            deeper: 
                                fn: {}

                done()



