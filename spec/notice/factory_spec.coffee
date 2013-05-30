require('nez').realize 'Factory', (Factory, test, context, should, os) -> 

    context 'create()', (it) -> 


        it 'requires config.messenger as a message handler', (done) -> 

            try
                
                new Factory().create()

            catch error 

                error.should.match /requires config\.messenger/
                test done



        it 'calls back with the notifier', (that) -> 

            RECEIVED = []

            nf = new Factory()
            nf.create { 

                #
                # notifierFactory.create() takes a hash of 
                # config which must include a messenger
                # function
                #

                messenger: (message) -> RECEIVED.push message

                #
                # it calls back with a notifyier to 
                # send messages
                # 

            }, (error, notify) -> 



                that 'is used to send messages', (done) -> 

                    RECEIVED = []

                    notify 'test message'

                    should.exist RECEIVED[0]
                    test done



                that 'formats the message', (done) -> 

                    RECEIVED = []

                    notify 'arg1 string', 'arg2 string'

                    RECEIVED[0].label.should.equal 'arg1 string'
                    RECEIVED[0].description.should.equal 'arg2 string'

                    test done



                that 'has a middleware registrar', (done) -> 

                    middleware1 = (msg, next) -> msg.propery1 = 'value1' and next()
                    middleware2 = (msg, next) -> msg.propery2 = 'value2' and next()

                    notify.use middleware1
                    notify.use middleware2

                    should.exist nf.middleware[0]
                    should.exist nf.middleware[1]

                    test done


                that 'throws if the middleware does not persist the pipeline', (done) -> 

                    #
                    # must call next()
                    #

                    try
                        
                        notify.use (msg, next) -> 

                            msg.some  = 'thing'
                            msg.other = 'stuff'

                    catch error

                        error.should.match /terminal middleware detected/
                        test done


                that 'passes the message through the registered middleware', (done) -> 


                    RECEIVED = []

                    notify.use (msg, next) -> 
                        

                        msg.source ||= {}
                        msg.source.hostname = os.hostname()
                        msg.source.type     = os.type()
                        msg.source.platform = os.platform()
                        msg.source.arch     = os.arch()

                        msg.source.extinfo       ||= {} 
                        msg.source.extinfo.uptime  = os.uptime()
                        msg.source.extinfo.loadavg = os.loadavg()
                        msg.source.extinfo.cpus    = os.cpus()

                        #throw new Error 'um?'

                        next()

                    notify.use (msg, next) -> 

                        msg.also = 'THIS'
                        next()

                     
                    notify 'LABEL', 'DESCRIPTION'

                    setTimeout -> 

                        RECEIVED[0].label.should.equal 'LABEL'
                        RECEIVED[0].description.should.equal 'DESCRIPTION'
                        
                        #
                        # this test may occasionally fail
                        #
                        RECEIVED[0].source.type.should.equal 'Darwin'
                        RECEIVED[0].also.should.equal 'THIS'
                        #console.log JSON.stringify RECEIVED, null, 2
                        test done
                    

                    ,10 # give it a moment


                that 'survives a light callbackblat', (done) -> 

                    setTimeout -> 

                        RECEIVED = []
                        notify 'hello?'

                    ,100

                    setTimeout ->

                        RECEIVED[0].label.should.equal 'hello?'
                        test done

                    ,200


                                                                # 
                                                                #  really!! need this to
                                                                #           hold off the
                                                                #           next test...
                                                                #
                that 'survives a serously heavy callbackblat', (done) -> 

                    class SpannerInTheWorks
                    class Xpert
                    class AntiqueConduit

                        constructor: (@mechanism) -> 
                        send: (  -> => ->
                            @mechanism.bigLever.pull.evenHarder.apply ( 
                                new SpannerInTheWorks(
                                    new Xpert(
                                        "no dude! ...you'll snap it"
                                    )
                                )
                            ), arguments

                        )()()


                    email = new AntiqueConduit bigLever: pull: evenHarder: -> notify.apply {spam:{spam:{spam:{}}}}, arguments


                    require('when/sequence')( [

                        -> 'wade through inbox'
                        -> 'attemt search'
                        -> 'whose it from again?'
                        -> 'dammit, maybe i can search by peer recipient?'
                        -> 'no, keep seaching by partial recollection of subject'
                        -> 'aaaah, there it is'
                        -> 'click reply'
                        -> 'wait, no...'
                        -> 'reply all'
                        -> 'is that everyone?'
                        -> 'search recipients!!'
                        -> 'click send'

                    ] ).then -> email.send 'Re: Irrelevant and entirely forgettable original subject', 'Hi all, ...'

                    setTimeout ->

                        RECEIVED.pop().label.should.match /entirely forgettable/

                    ,30
                    

