#
# TODO: errno for implementation exit codes
#

module.exports.terminal = (error, reject, callback) -> 
    
    reject error if typeof reject is 'function'
    if typeof callback == 'function' then callback error


module.exports.reservedMessage = (type) -> 
    
    return error = new Error "notice: '#{type}' is a reserved message type" 


module.exports.undefinedArg = (arg) -> 
    
    return error = new Error "notice: required arg #{arg}"


module.exports.alreadyDefined = (thingType, thingName) -> 
    
    return error = new Error "notice: #{thingType} '#{thingName}' is already defined"

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

