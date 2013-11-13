require! './utils'
_ = require 'underscore'

module.exports = class Step
  ({@actor, @context, step-def})->
    # step的name在workflow中是唯一的，所以不用id了
    _.extend @, _.pick step-def, 'name', 'isStartActive', 'isContextAware' # 注意！！！这里的深浅Copy问题
    @state = 'pending' # pending | active | acting | end
    @state = 'active' if step-def.is-start-active # TODO：enforce workflow的can-act，只有can-act时，才能将这些start steps的状态设置为active
    @can-act = step-def.can-act or -> true
    @can-end = step-def.can-end or -> true
    @act-times = 0

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
      # debug "Can't act on step: #{@name}, state: #{@state}"
      throw new Error "Can't defer-act on step: #{@name}, state: #{@state}" if @actor.is-defer and not to-waiting-defer # defer act can't act 要抛出异常给调用者（通常是人工任务）

  defer-act: (other-context-info)->
    debug "defer-act: #{@}"
    @act other-context-info, false

  _act: ->
    # debug "act on step: #{@name}"
    @workflow.state = 'started'
    @state = 'acting'
    @actor.act @context
    @act-times++
    @_after-act!

  _after-act: ->
    # debug "******** Actor callback at step: #{@name}"
    # 那些原来active，但是没有能acting（未通过can-act）的steps，由于此时context变化了，可能可以act了. 注意，只有定义为is-context-aware的step才会被重新评估。
    # 在先retry context aware，还是先active next上，这里采用了广度优先的算法，先retry c.a.
    @workflow.retry-context-aware-steps! 
    @_active-next!
    if @can-end.apply @context
      @state = 'done'
      @workflow.state = 'ended' if @workflow.is-going-to-end @
      debug "End step: #{@name}, act times: #{@act-times},  active-steps: #{@workflow.active-steps!}, acting-steps: #{@workflow.acting-steps!}"
    else
      # still in this step
      debug "Still in step: #{@name}, act times: #{@act-times},  active-steps: #{@workflow.active-steps!}, acting-steps: #{@workflow.acting-steps!}"
      @act!
    # if @_if-can-enter-next!
    #   @_act-next! # 如果是多个next的时候，不一定要can-end才能进入下一个Step≈
  
  _active-next: ->
    for next-step in @next
      # next-step的can-enter如果未给出，则满足@can-end进入next-step
      if (next-step.can-enter or @can-end).apply @context
        next-step.step.state = 'active'
        next-step.step.act!

  to-string: ->
    "Step: '#{@name}', state: #{@state}, act-times: #{@act-times}."



