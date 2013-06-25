require('nez').realize 'Task', (Task, test, context) -> 

    context 'contructor', (it) ->

        it 'creates a task with unique id', (done) -> 

            a = new Task 'title', {}
            z = new Task 'title', {}

            z.id.should.not.equal a.id
            test done
            
