_ = require 'underscore'

class Actor
  (@name)->

class Human-actor
  ->
    @is-defer = true

  act: (context)->
    # do nothing business. all business has already done by human.

  # act: (wf-id, s-id, context)->
  #   # act中操作的数据，不在工作流引擎里控制，或许今后用从data-source中取得
  #   # 将由用户界面emit对应事件，并且在数据中给出condition-context-after-act
  #   # debug "Actor register once on: wf://#{wf-id}/#{s-id}/done"
  #   @_wait-human-work wf-id, s-id, context

  # _wait-human-work: (wf-id, s-id, context)->
  #   is-defer = true

class Auto-actor
  (@buiness-handler)->
    @is-defer = false


  act: (context)->
    # do something on context, the business logic should carry on here!
    @buiness-handler.handle context # 注意：将来为了集成Web Service，要改造为异步方法

  #   @_call-auto-task wf-id, s-id, context

  # _call-auto-task: (wf-id, s-id, context)->
  #   is-defer = false


module.exports = Actor-factory =
  create-actor: (type)->
    if type is 'human' then new Human-actor! else new Auto-actor!
