require! ['./workflow-factory', './event-bus', './Workflow-store']
_ = require 'underscore'

module.exports = class Engine
  (db, done) ->
    (@store) <~ new Workflow-store db
    done @

  start: (done)->
    # 注意，目前我们将所有workflow装载入内存，将来要改善只加载pending和started的workflow，end的workflow在用户查询时，再加载。
    (@workflows) <~! @store.retrieve-all-workflows
    done!

  stop: (done)->
    <~! @store.save-all-workflows @workflows
    Workflow-store.con.drop-database done

  add: (workflow-def)-> #
    workflow = workflow-factory.create-workflow workflow-def
    workflow.store = @store
    @workflows.push workflow
    workflow.save!
    workflow

  human-start: (workflow-def)-> # 人工启动工作流时，需要act一次，将active steps至于等候def-act，等待人工执行的结果
    workflow = @add workflow-def
    for active-step in workflow.active-steps!
      active-step.act!
    workflow

  human-act-step: (wfid, step-name, human-act-result)->
    step = @get-step wfid, step-name
    next-act = step.defer-act human-act-result

  get-step: (wfid, step-name)->
    workflow = @get-workflow-by-id wfid
    for step in _.values workflow.steps
      return step if step.name is step-name

  get-all-running-workflow: ->
    @query-workflow -> true

  get-workflow-by-id: (wfid)->
    workflows = @query-workflow -> @.id is wfid
    workflows[0]

  query-workflow: (query)->
    results = []
    for workflow in @workflows
      results.push workflow if query.apply workflow, null
    results

  _load-config: ->
    # load engine config
    {}


 