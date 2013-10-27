* 1 
    * in hot swapped middleware `capsule.$$all` (and onther built-ins) are not defined
    * grep BUG_1
    * seems like loss of capsule's scope when entering the eval'd middleware
        * which appears to not be the case [here](https://github.com/nomilous/laboratory/commit/bd1aa8e897b09d64e66cc842b029a773556e528c)

    * FIXED: 
        * str.replace /regex/, '$$' drops a $ on the sub (only if there is more than 1)
        * caught aearly enought to change $$stuff to $stuff

