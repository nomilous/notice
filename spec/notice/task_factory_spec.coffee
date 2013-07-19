require('nez').realize 'TaskFactory', (TaskFactory, test, context) -> 

    context 'createTask()', (it) ->

        NOTIFIER = ->
        OPTS     = {}

        it 'creates a task with unique id', (done) -> 

            a = TaskFactory.createTask 'title', OPTS, NOTIFIER
            z = TaskFactory.createTask 'title', OPTS, NOTIFIER

            z.id.should.not.equal a.id
            test done

        it 'returns a promise', (done) -> 

            TaskFactory.createTask('title', OPTS, NOTIFIER).then.should.be.an.instanceof Function
            test done

        it 'issues notice of the task', (done) -> 

            TaskFactory.createTask 'title', OPTS, (title, opts, msgType, msgTenor) -> 

                msgType.should.equal 'task'
                msgTenor.should.equal 'normal'
                test done

