module.exports = 

    connect: -> 

        console.log 'Notice.connect', arguments
        callback = arg for arg in arguments
        callback null, notice: 'CLIENT'
        
