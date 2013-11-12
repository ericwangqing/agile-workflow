require! './utils'
_ = require 'underscore'

module.exports = class Step
  ({@actor, @context, step-def})->
    # step的name在workflow中是唯一的，所以不用id了
    _.extend @, _.pick step-def, 'name', 'is-start' # 注意！！！这里的深浅Copy问题
    @state = 'pending'
    @can-act = step-def.can-act
    @can-end =step-def.can-end
    @act-times = 0
    @is-waiting-defer = false


  set-next: (@next)->

  set-workflow: (@workflow)->

  act: ->
    debug "act on step: #{@name}"
    if @can-act.apply context
      @_act!
    else
      throw new Error "Can't act on step: #{@name}"

  defer-act: ->
    debug "defer act on step: #{@name}"
    if @is-waiting-defer
      @act-times++
      @___act!
    else  
      debug "Can't defer-act on when not wait-defer"

  _act: ->
    if @state in ['pending', 'done'] # 可多次执行 
      @state = 'acting'
      # @_callback-workflow name:'step:start'
    @__act!

  __act: ->
    is-defer = @actor.act @wf-id, @id, @context
    if not is-defer
      @act-times++
      @___act!
    else
      @is-waiting-defer = true
      @

  ___act: ->
    # debug "******** Actor callback at step: #{@name}"
    if @can-end.apply @context
      @state = 'done'
      @workflow.active-steps = _.without @workflow.active-steps, @
      @_act-next!
    else
      # still in this step
      debug "Still in step: #{@name}, act times: #{@act-times}"
      @act!

  _act-next: ->
    if @next 
      @workflow.active-steps.push @next
      @next.act!
    else
      @workflow.state = 'end'

  to-string: ->
    "Step: '#{@name}', state: #{@state}, act-times: #{@act-times}" + if @is-waiting-defer then ', is-waiting-defer.' else '.'



