require! './utils'
_ = require 'underscore'

module.exports = class Step
  ({@actor, @context, step-def})->
    # step的name在workflow中是唯一的，所以不用id了
    _.extend @, _.pick step-def, 'name', 'is-start' # 注意！！！这里的深浅Copy问题
    @state = 'pending'
    @can-act = step-def.can-act or -> true
    @can-end = step-def.can-end or -> true
    @act-times = 0
    @is-waiting-defer = false


  set-next: (@next)->

  set-workflow: (@workflow)->

  check-actable: !->
    throw new Error "Can't act on ended workflow" if @workflow.state is 'ended'
    throw new Error "Can't act on inactive step: #{@name}" if not (@state in ['active', 'acting'])


  act: ->
    @check-actable!
    if @actor.is-defer
      debug "wait on defer act: #{@name}"
      @is-waiting-defer = true
    else if @can-act.apply @context
      @_act!
    else
      debug "Can't act on step: #{@name}, state: #{@state}"

  defer-act: (human-act-result)->
    @check-actable!
    debug "defer act on step: #{@name}"
    @context = _.extend @context, human-act-result
    if @is-waiting-defer and can-act = @can-act.apply @context
      @is-waiting-defer = false
      @_act!
    else  
      debug "Can't defer-act. is-waiting-defer: #{is-waiting-defer}, can-act: #{can-act} "

  _act: ->
    debug "act on step: #{@name}"
    @workflow.state = 'started'
    @act-times++
    if @state in ['pending', 'active', 'done'] # 可多次执行 
      @state = 'acting'
    @__act!
    

  __act: ->
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
      @next.state = 'active'
      @workflow.active-steps.push @next
      @workflow.active-steps = _.uniq @workflow.active-steps
      @next.act!
    else
      @workflow.state = 'ended'

  to-string: ->
    "Step: '#{@name}', state: #{@state}, act-times: #{@act-times}" + if @is-waiting-defer then ', is-waiting-defer.' else '.'



