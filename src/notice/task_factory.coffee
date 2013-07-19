{asUniq} = require './decorators'
{defer}  = require 'when' 

#
# task factory
#  

exports.createTask = asUniq (id, title, opts, notifier) -> 

    console.log createTask: arguments

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

    opts.id = id

    notifier title, opts, 'task', 'normal'


    #
    # return the promise
    # 

    task.promise




