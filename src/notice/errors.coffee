#
# TODO: errno for implementation exit codes
# TODO: more context into error outputs, eg, which .thing, and what was .propery at the time
# 

module.exports.terminal = (error, reject, callback) -> 
    
    reject error if typeof reject is 'function'
    if typeof callback == 'function' then callback error


module.exports.reservedCapsule = (type) -> 
    
    return error = new Error "notice: '#{type}' is a reserved capsule type" 

module.exports.missingConfig = (opt, module) -> 
    
    return error = new Error "notice: #{module} requires opt #{opt}"

module.exports.undefinedArg = (arg, functionSignature) -> 

    if functionSignature?

        return error = new Error "notice: #{functionSignature} requires arg #{arg}"
    
    return error = new Error "notice: requires arg #{arg}"

module.exports.argumentException = -> (arg, functionSignature, expectation) -> 

    return error = new Error "notice: expected #{functionSignature} with #{arg} #{expectation}"


module.exports.alreadyDefined = (thingType, thingName) -> 
    
    return error = new Error "notice: #{thingType} '#{thingName}' is already defined"

module.exports.invalidAction = (action, reason) -> 

    return error = new Error "notice: invalid use of #{action} '#{reason}'"

module.exports.disconnected = (originName) -> 
    
    return error = new Error "notice: origin '#{originName}' disconnected"

module.exports.connectRejected = (originName, rejection) -> 
    
    switch rejection.reason

        when 'already connected' then return error = new Error( 
            "notice: origin '#{originName}' rejected - #{rejection.reason} from #{rejection.pid}.#{rejection.hostname}"
        )

    return error = new Error( 
        "notice: origin '#{originName}' rejected - #{rejection.reason}"
    )

