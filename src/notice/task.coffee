{asUniq} = require './decorators'
{defer}  = require 'when' 

#
# task factory
# 

exports.create = asUniq (id, notifier, title, opts) -> 

    #
    # task is a deferral
    #

    task = defer()

    #
    # assign id to promise
    #

    Object.defineProperty task.promise, 'id', 
        enumerable: true
        writable: false
        value: id


    #
    # TEMPORARY
    #

    setTimeout (->

        task.resolve 'TEST'

    ), 100


    #
    # return the promise
    # 

    task.promise




