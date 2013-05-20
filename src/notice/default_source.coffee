path = require 'path'

module.exports = -> 

    for line in Error.apply(this).stack.split('\n')

        #
        # probably not windows friendly
        #

        console.log 'line --->', line

        continue unless match = line.match /\((.*)\/node_modules\//
        return path.basename match[1]


    return 'default'
