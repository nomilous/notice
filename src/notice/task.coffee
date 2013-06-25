{asUniq} = require './decorators'


module.exports = class Task 

    constructor: asUniq (@id, @title, @opts) -> 
    