// 
// Example personal message middleware
// 
// $HOME/.notice/middleware.js
//

module.exports = {

    // 
    // Middleware per 'origin name'
    // ----------------------------
    //
    // Optional
    // 
    // * This will override the `defaultFn` middleware as
    //   assigned at creation of the notifier.
    //   
    //    ie. notice = Notice.create(originName, defaultFn)
    // 
    // * This will run after all other middleware as assigned 
    //   using the `notice.use(middlewareFn)` registrar.
    // 

    'origin name': function( msg, next ) {

        next();

    },


    // 
    // Middleware for all 'origin name's
    // ---------------------------------
    //
    // Optional
    // 
    // * This will always run, irrespective of the message origin
    // * This will run after all middleware
    //

    all: function( msg, next ) {

        //
        // always run, no matter the origin name of the message
        //

        next();

    }

}
