{ticker, _ticker} = require '../../lib/management/ticker'
should = require 'should'


describe 'ticker', ->

    before -> 

        @notifier = 
            title: 'NOTIFIER'
            $$tick: => @tick.apply null, arguments
            

    beforeEach ->
        @tick = ->


    it 'has a hash for keeping running timers', (done) ->

        instance = ticker()
        should.exist _ticker().timers
        done()


    it 'exposes a register function for tick options and assignmant of the notifier to tick into', (done) -> 

        instance = ticker()
        instance.register.should.be.an.instanceof Function
        done()


    it 'assigns the notifier', (done) -> 

        instance = ticker()
        instance.register @notifier, {}
        _ticker().notifier.should.equal @notifier
        done()


    it 'defaults the interval to 1 second if unspecified and stores the created intervalTimer', (done) -> 


        instance = ticker()
        instance.register @notifier, 
            ticks:
                CODE: 
                    interval: 1000

        _ticker().timers.NOTIFIER.CODE.interval.should.equal 1000
        _ticker().timers.NOTIFIER.CODE.timer._idleTimeout.should.equal 1000
        done()


    it 'calls notifier.$$tick with the code', (done) -> 

        instance = ticker()
        instance.register @notifier,
            ticks:
                CODE1: 
                    interval: 100
                CODE2: 
                    interval: 1050

        CODES = []
        @tick = (code, {seq}) -> 
            if code == 'CODE1' then CODES.push code 
            if code == 'CODE2' 
                CODES[7..9].should.eql ['CODE1', 'CODE1', 'CODE1']
                seq.should.equal 0
                done()


    it 'accepts tick defs from super config', (done) -> 

        instance = ticker ticks: global: interval: 10000
        instance.register @notifier
        _ticker().timers.NOTIFIER.global.timer._idleTimeout.should.equal 10000
        done()


    it 'tick defs from opts override', (done) -> 

        instance = ticker ticks: global: interval: 10000
        instance.register @notifier, ticks: global: interval: 1000
        _ticker().timers.NOTIFIER.global.timer._idleTimeout.should.equal 1000
        done()



