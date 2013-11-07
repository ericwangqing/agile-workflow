module.exports = class Workflow
  (@id, @name, @steps, @start-step, @start-condition-context, @engine-callback)->
    @state = 'pending'
    @engine-callback event =
      name: 'workflow:created'
      wf-id: @id
      wf-current-state: @state

  step-event-handler: !(event)~>
    @engine-callback event <<<
      wf-id: @id
      wf-current-state: @state
    if event.name is 'step:start' and @state is 'pending'
      @state = 'start' 
      @engine-callback event =
        name: 'workflow:start'
        wf-id: @id
        wf-current-state: @state

    if event.is-from-last-step and  event.name is 'step:end'
      @state = 'end' 
      @engine-callback event =
        name: 'workflow:end'
        wf-id: @id
        wf-current-state: @state


 
  start: !->
    @start-step.act @start-condition-context, @step-event-handler

  get-step-id-by-name: (name)->
    @steps[name].id
