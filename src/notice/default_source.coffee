path = require 'path'

module.exports = -> 

    for line in Error.apply(this).stack.split('\n')

        #
        # probably not windows friendly
        # 
        # match 'reluctantly' (?) for the shortest possible .*
        # that preceeds a node_modules directory and return
        # it's last path part
        #

        continue unless match = line.match /\((.*?)\/node_modules\//
        return path.basename match[1]


    return 'default'
