module.exports = class NoticeableClass

    #
    # api tool with noticeability (class example)
    # -------------------------------------------
    # 

    constructor: ->

        @exposedProperty = deeper: and: deeper: 'value'

        @apiExposedFunction = (opts, callback) -> 

            #
            # opts? ##undecided
            # 
            # and the whole internet is just one asyncronous rung uptree
            # 
            
            setTimeout (->
                callback null, Infinity
            ), 3000


        @apiExposedFunction.$$notice = {}


Infinity = 

    endlessly: more: 'stuff'
    with: another: new NoticeableClass 'inside it'

