{argumentException} = require '../notice/errors'

testable = undefined
module.exports._middleware = -> testable
module.exports.middleware = (config = {}) ->

    testable = local = 

        slots: {}
        bottomSlot: 0
        array1: []
        array2: []
        active: 'array1'

        firstMiddleware: (next) -> next(); ### PENDING ### 
        lastMiddleware:  (next) -> next(); ### PENDING ### 

        first: (fn) -> 
            return unless typeof fn is 'function'
            return unless local.firstMiddleware.toString().match /PENDING/
            local.firstMiddleware = fn
            local.reload()

        last: (fn) -> 
            return unless typeof fn is 'function'
            return unless local.lastMiddleware.toString().match /PENDING/
            local.lastMiddleware = fn
            local.reload()


        nextSlot: -> ++local.bottomSlot

        update: ({slot, title, description, enabled, fn}) -> 

            slot ?= local.nextSlot()

            unless typeof slot is 'number'
                throw argumentException 'opts.slot', 'notice.use(opts, fn)', 'as whole number'

            unless Math.floor(slot) == slot
                throw argumentException 'opts.slot', 'notice.use(opts, fn)', 'as whole number'

            unless slot > 0
                throw argumentException 'opts.slot', 'notice.use(opts, fn)', 'as positive number'

            unless title? and fn?
                throw argumentException 'opts.title and fn', 'notice.use(opts, fn)'

            unless typeof fn is 'function'
                throw argumentException 'fn', 'notice.use(opts, fn)', 'as function'


            if slot > local.bottomSlot then local.bottomSlot = slot + 1

            local.slots[slot] = 
                slot: slot
                title: title
                description: description
                type: 'usr'
                enabled: enabled
                fn: fn

            local.reload()


        reload: -> 

            #
            # TODO: * pend reload till signal 
            # TODO: * emit $$ready 'pack_id'
            #

            next = if local.active == 'array1' then 'array2' else 'array1'

            sort = []
            sort[parseInt slot] = slot for slot of local.slots

            array = local[next]
            array.length = 0

            array.push 
                title: 'first'
                type:  'sys'
                fn: local.firstMiddleware

            for num in sort
                continue unless num
                mware = local.slots[num]
                continue unless mware.enabled is true
                array.push mware

            array.push 
                title: 'last'
                type:  'sys'
                fn: local.lastMiddleware

            local.active = next


        running: -> local[local.active]

    api = 

        update:  local.update
        running: local.running
        first:   local.first
        last:    local.last




                    #
                    # ##ideas
                    # 
                    # * the middleware, contained in a capsule
                    #      * provides a change watcher
                    #      * uuid
                    # * switching middleware, instruction via the pipeline in addition to the api
                    # * middleware packs (a contiguous, identifiable set)
                    #      * hub runs a pack
                    #      * can switch betweeen packs
                    #           * nice for preloading an ugrade pending ideal switch moment
                    #           * switch back if it blows up
                    #  
                    #      == suggests sluce ==
                    #               
                    #              * a 'first' middleware that queues when activated
                    #              * and can open the floodgate carefully
                    #              * to only release a trickle onto the newly upgraded bus
                    #              * to determine if a rollback (and return to the DrawingBoard) is necessary
                    # 




