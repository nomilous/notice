* 1 
    * in hot swapped middleware `capsule.$$all` (and onther built-ins) are not defined
    * grep BUG_1
    * seems like loss of capsule's scope when entering the eval'd middleware
        * which appears to not be the case [here](https://github.com/nomilous/laboratory/commit/bd1aa8e897b09d64e66cc842b029a773556e528c)