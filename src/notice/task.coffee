{asUniq} = require './decorators'

module.exports = create: asUniq (id, title) -> 

    console.log 'create task', 

        id:    id
        title: title