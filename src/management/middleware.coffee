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

        nextSlot: -> ++local.bottomSlot

        update: ({slot, title, description, enabled, fn}) -> 

            slot ?= local.nextSlot()

            unless typeof slot is 'number'
                throw argumentException 'opts.slot', 'notice.use(opts, fn)', 'as whole number'

            unless Math.floor(slot) == slot
                throw argumentException 'opts.slot', 'notice.use(opts, fn)', 'as whole number'

            unless title? and fn?
                throw argumentException 'opts.title and fn', 'notice.use(opts, fn)'



            unless typeof fn is 'function'
                throw argumentException 'fn', 'notice.use(opts, fn)', 'as function'



            if slot > local.bottomSlot then local.bottomSlot = slot + 1

            local.slots[slot] = arguments[0]

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
            for num in sort
                continue unless num
                mware = local.slots[num]
                continue unless mware.enabled is true
                array.push mware
            local.active = next


        runningArray: -> local[local.active]

    api = 

        update: local.update
        runningArray: local.runningArray


