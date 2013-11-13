require! './utils'
_ = require 'underscore'

module.exports = class Step
  ({@actor, @context, step-def})->
    # step的name在workflow中是唯一的，所以不用id了
    _.extend @, _.pick step-def, 'name', 'is-start-active' # 注意！！！这里的深浅Copy问题
    @state = 'pending' # pending | active | waiting | acting | end
    @state = 'active' if step-def.is-start-active
    @can-act = step-def.can-act or -> true
    @can-end = step-def.can-end or -> true
    @act-times = 0


  set-next: (@next)->

  set-workflow: (@workflow)->

  check-state-actable: !->
    throw new Error "Can't act on ended workflow" if @workflow.state is 'ended'
    # 现在的考虑是允许step被重新进入，也就是end之后，还可以再次开始
    throw new Error "Can't act on inactive step: #{@name}" if @state is 'pending' #not (@state in ['active', 'acting', 'waiting'])



  act: (other-context-info, to-waiting-defer)->
    to-waiting-defer = true if typeof to-waiting-defer is 'undefined'
    _.extend @context, other-context-info
    @check-state-actable!
    if @can-act.apply @context and not (@actor.is-defer and to-waiting-defer)
      @_act!
    else
      debug "Can't act on step: #{@name}, state: #{@state}"
      throw new Error "Can't defer-act on step: #{@name}, state: #{@state}" if @actor.is-defer and not to-waiting-defer # defer act can't act 要抛出异常给调用者（通常是人工任务）

  defer-act: (other-context-info)->
    debug "defer-act: #{@}"
    @act other-context-info, false

  _act: ->
    debug "act on step: #{@name}"
    @workflow.state = 'started'
    @state = 'acting'
    @actor.act @context
    @act-times++
    @_after-act!
    

  _after-act: ->
    # debug "******** Actor callback at step: #{@name}"
    if @can-end.apply @context
      @state = 'done'
    else
      # still in this step
      debug "Still in step: #{@name}, act times: #{@act-times}"
      @act!
    # @workflow.try-act-active-steps! # 那些原来active，但是没有能acting（未通过can-act）的steps，由于此时context变化了，可能可以act了
    if @_if-can-enter-next!
      @_act-next! # 如果是多个next的时候，不一定要can-end才能进入下一个Step≈
  _if-can-enter-next: ->
    @can-end.apply @context

  _act-next: ->
    if @workflow.is-going-to-end @
      @workflow.state = 'ended'
    else
      # if @next.state isnt 'acting' # 否则已经开始了，不需要
      @next.state = 'active'
      @next.act!

  to-string: ->
    "Step: '#{@name}', state: #{@state}, act-times: #{@act-times}."



