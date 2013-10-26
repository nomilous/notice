should     = require 'should'
{recursor} = require '../../lib/management/recursor' 

describe 'recursor', -> 

    before -> 

        @query = undefined

    it 'responds method not allowed unless GET', (done) -> 

        instance = recursor
            methodNotAllowed: -> done()

        instance [@query], method: 'POST'


    it 'responds object not found id no notifier / hub at uuid', (done) -> 

        instance = recursor
            objectNotFound: -> done()
            hubContext: hubs: {}

        instance [@query, 'UUID'], { method: 'GET' }


    it 'serializes the notifier at level2', (done) -> 

        instance = recursor
            hubContext: 
                hubs: 
                    UUID: 
                        serialize: (level) -> 
                            level.should.equal 2
                            done()
                            throw 'go no further'

        try instance [@query, 'UUID'], { method: 'GET' }


    it 'responds object not found if searialization[type] does not exist', (done) -> 

        instance = recursor
            objectNotFound: -> done()
            hubContext: 
                hubs: 
                    UUID: 
                        serialize: (level) -> 
                            notType: test: 'value'

            'type'

        instance [@query, 'UUID'], { method: 'GET' }


    it 'responds with 200 and serializeation[type] as JSON string', (done) -> 

        instance = recursor
            hubContext: 
                hubs: 
                    UUID: 
                        serialize: (level) -> 
                            type: 
                                test: 'value'
                                deeper: 
                                    and: 'this'

            'type'

        STATUS = undefined
        RESULT = undefined
        instance [@query, 'UUID'], { method: 'GET' }, 

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
                hubs: 
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

        instance [@query, 'UUID'], { method: 'GET' }, 
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


    it '((for now)) it listifies arrays', (done) -> 

        fn = (opts, callback) -> 
        fn.$$notice = {}

        instance = recursor
            hubContext: 
                hubs: 
                    UUID: 
                        serialize: (level) -> 
                            type: 
                                test: ['one','two','three']
                                more:
                                    here: [4, five:5, 6]

            'type'

        instance [@query, 'UUID'], { method: 'GET' }, 
            end: ->
            writeHead: ->
            write: (result) -> 

                JSON.parse( result ).should.eql

                    test:
                        '0': 'one'
                        '1': 'two'
                        '2': 'three'
                    more:
                        here:
                            '0': 4
                            '1': five: 5
                            '2': 6

                done()


    it 'recurses only along the "deeper" path (if provided) and returns the thing at the end', (done) -> 

        instance = recursor
            hubContext: 
                hubs: 
                    UUID: 
                        serialize: (level) -> 
                            type: 
                                test: ['one','two','three']
                                more:
                                    here: [4,five: 5,6]
            'type'

        instance [@query, 'UUID','more/here/1'], { method: 'GET' }, 
            end: ->
            writeHead: ->
            write: (result) -> 

                JSON.parse( result ).should.eql five: 5
                done()


    it 'calls the exposed function on "deeper" path, appending the tree', (done) -> 

        fn = (opts, callback) -> 
            #console.log huh: 1
            callback null, AND: MORE: tree: here: 'too'

        fn.$$notice = {}

        instance = recursor
            hubContext: 
                hubs: 
                    UUID: 
                        serialize: (level) -> 
                            type: 
                                test: 
                                    deeper: fn

            'type'

        instance [@query, 'UUID','test/deeper/AND/MORE/tree'], { method: 'GET' }, 
            end: ->
            writeHead: ->
            write: (result) -> 

                JSON.parse( result ).should.eql here: 'too'
                done()

    it 'supports more than sidebyside 1 function on "deeper" path', (done) -> 

        fn = (opts, callback) -> callback null, AND: MORE: tree: here: 'too'
        fn.$$notice = {}

        instance = recursor
            hubContext: 
                hubs: 
                    UUID: 
                        serialize: (level) -> 
                            type: 
                                test: 
                                    deeper1: fn
                                    deeper2: fn


            'type'

        instance [@query, 'UUID','test/deeper2/AND/MORE/tree'], { method: 'GET' }, 
            end: ->
            writeHead: ->
            write: (result) -> 

                JSON.parse( result ).should.eql here: 'too'
                done()




