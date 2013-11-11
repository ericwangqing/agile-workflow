require! './Step'
module.exports = class Workflow extends Step # 这样workflow就可以作为step使用
  (@id, @name, @steps, @start-step, @start-condition-context, @engine-callback)->
    @state = 'pending'
    @current-step = null
    @_callback-engine name: "workflow:created:#{@id}"

  initial: ->
    @

  act: ->
    @current-step = @start-step if @current-step is null
    @current-step.act @start-condition-context, @step-event-handler
    @

  get-step-id-by-name: (name)->
    @steps[name].id

  step-event-handler: !(event)~>
    @_callback-engine event
    # @_update-current-step event
    @translate-to-and-handle-workflow-event event

  translate-to-and-handle-workflow-event: !(event)->
    if event.name is 'step:start' and @state is 'pending'
      @state = 'start' 
      @_callback-engine {name: "workflow:start:#{@id}", next-act: @current-step}

    if event.name is 'step:acting'
      @_callback-engine {name: "workflow:acted-on:#{@id}/#{@current-step.id}", next-act: @current-step}

    if event.name is 'step:end'
      # debug "workflow emit: workflow:acted-on:#{@id}/#{@current-step.id}"
      @_callback-engine {name: "workflow:acted-on:#{@id}/#{@current-step.id}", next-act: @current-step.next}
      if event.is-from-last-step 
        @state = 'end'
        @_callback-engine name: "workflow:end:#{@id}"
      else
        @current-step = @current-step.next
        @current-step.act event.condition-context, @step-event-handler
        @_callback-engine {name: "workflow:waiting-human-on:#{@id}/#{@current-step.id}", next-act: @current-step}

  # _update-current-step: !(event)->
  #   @current-step = @current-step.next if event.name is 'step:end'

  _callback-engine: !(data)->
    @engine-callback {wfid: @id, state: @state} <<< data 

