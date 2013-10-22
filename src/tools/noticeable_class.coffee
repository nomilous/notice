module.exports = class NoticeableClass

    #
    # api tool with noticeability (class example)
    # -------------------------------------------
    # 

    constructor: ->

        @apiProperty = deeper: and: deeper: 'value'

        @apiFunction = (opts, callback) -> 

            #
            # opts? ##undecided
            # 
            # and the whole internet is just one asyncronous rung uptree
            # 
            
            setTimeout (->

                callback null, Infinity

            ), 400


        @apiFunction.$$notice = {}

        @apiFunction2 = (opts, callback) -> callback null, this: 1
        @apiFunction2.$$notice = {}

        @array = [

            'this'
            'is'
            'listified'

        ]



Infinity = 

    endlessly: more: 'stuff'
    with: another: new NoticeableClass 'inside it'

