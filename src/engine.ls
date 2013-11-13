require! ['./workflow-factory', './event-bus']
_ = require 'underscore'

workflow-store =
  retrieve-all-running-workflows: -> []

module.exports = class Engine
  (@store, config) ->
    @workflows = (@store or workflow-store).retrieve-all-running-workflows!

  add: (workflow-def, resource)-> #
    workflow = workflow-factory.create-workflow workflow-def, resource, @_event-handler
    @workflows.push workflow
    workflow

  human-execute: (workflow-def, resource)-> # 人工执行时，需要act一次，才能等候def-act，给入人工执行的结果
    workflow = @add workflow-def, resource
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


 