require! './event-bus'
module.exports = class Human-actor
  act: (wf-id, s-id, done)->
    # act中操作的数据，不在工作流引擎里控制，或许今后用从data-source中取得
    # 将由用户界面emit对应事件，并且在数据中给出condition-context-after-act
    event-bus.on "wf://#{wf-id}/#{s-id}/done", done
