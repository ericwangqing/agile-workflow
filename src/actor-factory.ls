require! './event-bus'
class Actor
  (@name)->

class Human-actor
  act: (wf-id, s-id, done)->
    # act中操作的数据，不在工作流引擎里控制，或许今后用从data-source中取得
    # 将由用户界面emit对应事件，并且在数据中给出condition-context-after-act
    # debug "Actor register once on: wf://#{wf-id}/#{s-id}/done"
    @_wait-human-work wf-id, s-id, done

  _wait-human-work: (wf-id, s-id, done)->
    event-bus.once "wf://#{wf-id}/#{s-id}/done", done

class Auto-actor
  act: (wf-id, s-id, done)->
    @_call-auto-task wf-id, s-id, done

  _call-auto-task: (wf-id, s-id, done)->
    done!


module.exports = Actor-factory =
  create-actor: (type)->
    if type is 'human' then new Human-actor! else new Auto-actor!
