module.exports = class NoticeableClass

    #
    # api tool with noticeability (class example)
    # -------------------------------------------
    # 

    constructor: ->

        @exposedProperty = 
            deeper: and: deeper: 'value'

        Object.defineProperty @, 'apiExposedFunction',
            enumerable: true
            get: -> 

                #
                # this is a property that returns a function
                # ------------------------------------------
                # 
                # * ideally i would have rather used the commented
                #   function at the foot of this file, but i couldn't
                #   make it enumerate.
                # 

                exported = (opts, callback) -> 

                    #
                    # * the customary asynchronous callee
                    #

                    setTimeout (->

                        callback null, Infinity

                    ), 3000

                #
                # the returned function is  declared as $$notable
                # -----------------------------------------------
                #
                # * hash is a placeholder for future configables
                # * for now, the presense of the nested property
                #   informs the API of the $$notable entity.
                # 

                exported.$$notice = {}
                return exported


            set: (value) -> -> -> -> """

                has not been thought about to any depth yet,
                other than a vague sense,
                of wanting to PUT POST in

            """


    # exposedFunction: (opts, callback) -> 
    #     setTimeout (-> 
    #         callback null, resulting: 'thing'
    #     ), 1000


Infinity = 

    endlessly: more: 'stuff'
    with: another: new NoticeableClass 'inside it'

