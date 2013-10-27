module.exports = class NoticeableClass

    #
    # api tool with noticeability (class example)
    # -------------------------------------------
    # 

    constructor: ->

        @apiProperty = deeper: 'value'

        @apiFunction = (opts, callback) -> 

            # console.log NOTICE_OPTS: opts

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
            
            setTimeout (->

                callback null, async: jump: in: 'path'

            ), 400


        @apiFunction.$notice = {}


        @array = [

            'this'
            'is'
            'listified'

        ]

