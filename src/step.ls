require! './utils'
_ = require 'underscore'

module.exports = class Step
  (@wf-id, @actor, step-def)->
    _.extend @, _.pick step-def, 'name' # 注意！！！这里的深浅Copy问题
    @id = 's-' + utils.get-uuid!
    @state = 'pending'
    @can-act = step-def.can-act
    @can-end =step-def.can-end
    @act-times = 0

  set-next: (step)->
    @next = step

  act: !(condition-context, wf-callback)->
    @wf-callback = wf-callback
    if @can-act.apply condition-context
      @_act!
    else
      @_callback-workflow name: 'step-can-not-act'

  _act: !->
    @act-times++
    if @state in ['pending', 'done'] # 可多次执行 
      @state = 'acting'
      @_callback-workflow name:'step:start'
    @__act!

  __act: !->
    (cc-after-act) <~! @actor.act @wf-id, @id
    if @can-end.apply cc-after-act
      @state = 'done'
      @_act-next cc-after-act
    else
      # still in this step
      @_callback-workflow name:'step-acting'

  _act-next: !(cc-after-act)->
    if @next 
      @_callback-workflow name:'step:end' # 注意!!! 以下两步顺序不能变！
      @next.act cc-after-act, @wf-callback
    else
      @_callback-workflow {name:'step:end' is-from-last-step: true}

  _callback-workflow: !(data)->
      @wf-callback {step-id: @id, step-name: @name} <<< data




