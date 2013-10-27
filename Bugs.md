* 1 
    * in hot swapped middleware `capsule.$$all` (and onther built-ins) are not defined
    * grep BUG_1
    * seems like loss of capsule's scope when entering the eval'd middleware
