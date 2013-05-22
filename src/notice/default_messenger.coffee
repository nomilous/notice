module.exports = (msg) -> 

    #
    # a default messenger
    #
    
    console.log(

        "[default messenger]/notice/%s/%s from:'%s' label:'%s' description:'%s'"
        msg.context.type
        msg.context.tenor
        msg.source.ref
        msg.content.label
        msg.content.description

    )

