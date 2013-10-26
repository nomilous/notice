module.exports = class NoticeableClass

    #
    # api tool with noticeability (class example)
    # -------------------------------------------
    # 

    constructor: ->

        @apiProperty = deeper: 'value'

        @apiFunction = (opts, callback) -> 

            #
            # TODO: opts? ##undecided
            # TODO: opts.method (from the http method)
            # TODO: opts.body (event emitter or predecoded per opts)
            #  
            # 
            # and the whole internet is just one asyncronous rung uptree
            # 
            # 
            # 

            console.log NOTICE_OPTS: opts
            
            setTimeout (->

                callback null, async: jump: in: 'path'

            ), 400


        @apiFunction.$$notice = {}


        @array = [

            'this'
            'is'
            'listified'

        ]



Infinity = 

    endlessly: more: 'stuff'
    with: another: new NoticeableClass 'inside it'

