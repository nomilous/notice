{memoryUsage} = process

module.exports.health = (capsule, callback) -> 
    
    capsule.memory = memoryUsage()
    callback()

