require! './utils'
_ = require 'underscore'

module.exports = class Step
  (@wf-id, @actor, step-def)->
    _.extend @, _.pick step-def, 'name' # 注意！！！这里的深浅Copy问题
    @id = 's-' + utils.get-uuid!
    @state = 'pending'
    @can-start = step-def.can-start
    @can-end =step-def.can-end
    @act-times = 0

  set-next: (step)->
    @next = step

  act: (condition-context, wf-callback)->
    if @can-start condition-context
      @act-times++
      @state = 'executing'
      wf-callback {name:'step:start', step-id: @id, step-name: @name}

      (cc-after-act) <~! @actor.act @wf-id, @id
      if @can-end cc-after-act
        @state = 'done'
        event = {name:'step:end', step-id: @id, step-name: @name}
        if @next 
          wf-callback event
          @next.act cc-after-act, wf-callback
        else
          event.is-from-last-step = true 
          wf-callback event
      else
        # still in this step
        wf-callback {name:'step-acting', s-id: @id, times: @act-times}
    else
      wf-callback {name:'step-can-not-start', s-id: @id}


