module.exports = class NoticeableClass

    #
    # api tool with noticeability (class example)
    # -------------------------------------------
    # 

    constructor: ->

        @apiProperty = deeper: 'value'

        @apiFunction = (opts, callback) -> 

            #
            # opts? ##undecided
            # 
            # and the whole internet is just one asyncronous rung uptree
            # 
            
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

