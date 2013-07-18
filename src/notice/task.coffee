{asUniq} = require './decorators'

#
# task factory
# 

exports.create = asUniq (id, notifier, title, opts) -> 

    console.log createTask: arguments

    task = new Object

    Object.defineProperty task, 'id', 
        enumerable: true
        writable: false
        value: id


