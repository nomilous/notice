require('nez').realize 'Notify', (Notify, test, context, should, Configure) -> 

    MSG = null

    Configure 

        source: 'MESSAGE SOURCE'
        messenger: (msg) -> 

            MSG = msg


    context 'send()', (it) -> 


        it 'inserts source with ref and time into message', (done) -> 

            Notify.send()

            MSG.source.ref.should.equal 'MESSAGE SOURCE'
            should.exist MSG.source.time
            test done


        it 'accepts a hash of message key: "values"', (done) -> 

            Notify.send 'umm?': 'why?', well: 'because!'

            MSG.content['umm?'].should.equal 'why?'
            MSG.content.well.should.equal 'because!'
            test done


        it 'defaults message context.type to "event"', (done) -> 

            Notify.send 
                discovery: 'complete'
                proficiency: 4 / 7

            MSG.context.type.should.equal 'event'
            test done


        it 'defaults single string arguments to content.label', (done) -> 

            Notify.send 'some thing'

            MSG.content.label.should.equal 'some thing'
            test done


        it 'defaults double arg as both string to label and description', (done) -> 

             Notify.send 'red lorry yellow lorry', """

                ```bash

                # 
                # osx
                # 

                RLYL=""
                for (( j=10; j>i; j-- )); do RLYL="$RLYL red lorry yellow lorry"; done
                say -r 500 $RLYL

                ```

             """

             MSG.content.label.should.equal 'red lorry yellow lorry'
             MSG.content.description.should.match /osx/
             test done



