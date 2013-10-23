{argumentException} = require '../notice/errors'

testable = undefined
module.exports._middleware = -> testable
module.exports.middleware = (config = {}) ->

    testable = local = 

        slots: {}

        nextSlot: -> 

            console.log next: 1
            1

        update: ({slot, title, description, enabled, fn}, callback) -> 

            slot ?= local.nextSlot()

            throw argumentException( 

                #'mware.slot', 'middleware.update(mware)', 'as number'
                'opts.slot', 'notice.use(opts, fn)', 'as number'

            ) unless typeof slot is 'number'

            console.log UPDATE: slot


    api = 

        update: local.update


