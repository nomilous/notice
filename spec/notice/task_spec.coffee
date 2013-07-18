require('nez').realize 'Task', (Task, test, context) -> 

    context 'create()', (it) ->

        it 'creates a task with unique id', (done) -> 

            a = Task.create 'title', {}
            z = Task.create 'title', {}

            z.id.should.not.equal a.id
            test done

        it 'returns a promise', (done) -> 

            Task.create('title', {}).then.should.be.an.instanceof Function
            test done

