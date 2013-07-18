require('nez').realize 'Task', (Task, test, context) -> 

    context 'create()', (it) ->

        it 'creates a task with unique id', (done) -> 

            a = Task.create 'title', {}
            z = Task.create 'title', {}

            console.log a.id = 1
            console.log a

            z.id.should.not.equal a.id
            test done

