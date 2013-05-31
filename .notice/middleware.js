// 
// Example personal message middleware
//
// - Always loaded last on the middleware pipeline
// 
// $HOME/.notice/middleware.js
//

module.exports = { 

    default: function( msg, next ) {

        //
        // console.log( JSON.stringify( msg.content, null, 2 ) );
        // console.log( msg.context );
        // console.log( msg );
        //
        // 
        // do anything: 
        // ============
        // 
        // require 'hubot', 'hipchat', 'growl', 'socket.io', 'graphite', 'umm?'
        //
        // but
        // ===
        //
        // call next()
        // 

        msg.anything = 'you want'
        next();

    }

}
