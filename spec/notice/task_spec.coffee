require('nez').realize 'Task', (Task, test, context) -> 

    context 'create()', (it) ->

        it 'creates a task', (done) -> 

            Task.create 'title'