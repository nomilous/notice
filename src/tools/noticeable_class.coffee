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

            console.log 'loading...': opts
            
            setTimeout (->

                callback null, Infinity

            ), 3000


        @apiFunction.$$notice = {}


Infinity = 

    endlessly: more: 'stuff'
    with: another: new NoticeableClass 'inside it'

