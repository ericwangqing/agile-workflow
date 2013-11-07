require! './Step'
module.exports = class Workflow extends Step # 这样workflow就可以作为step使用
  (@id, @name, @steps, @start-step, @start-condition-context, @engine-callback)->
    @state = 'pending'
    @_callback-engine name: 'workflow:created'

  act: !->
    @start-step.act @start-condition-context, @step-event-handler

  get-step-id-by-name: (name)->
    @steps[name].id

  step-event-handler: !(event)~>
    @_callback-engine event
    @translate-to-and-handle-workflow-event event

  translate-to-and-handle-workflow-event: !(event)->
    if event.name is 'step:start' and @state is 'pending'
      @state = 'start' 
      @_callback-engine name: 'workflow:start'

    if event.is-from-last-step and  event.name is 'step:end'
      @state = 'end' 
      @_callback-engine name: 'workflow:end'

  _callback-engine: !(data)->
    @engine-callback {wf-id: @id, wf-current-state: @state} <<< data

