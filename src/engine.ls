require! ['./workflow-factory', './event-bus']
_ = require 'underscore'

workflow-store =
  retrieve-all-running-workflows: -> []

debug-event = !(e)->
  step-message = if e.step-name then " step: #{e.step-name}," else ""
  message = "#{e.name},#{step-message} workflow-state: #{e.state}"
  debug message


module.exports = class Engine
  (@store, config) ->
    self = @
    @workflows = (@store or workflow-store).retrieve-all-running-workflows!
    @config = if config then config else @_load-config!
    # @event-bus = event-bus

  start: !(cfg)->
    [workflow.act! for workflow in @workflows]
    @

  add: (workflow-def, resource)-> #
    workflow = workflow-factory.create-workflow workflow-def, resource, @_event-handler
    @workflows.push workflow
    workflow.initial! # 初始化！

  execute: !(workflow-def, resource, callback)-> 
    # debug "engine execute wf with callback: ", callback
    workflow = @add workflow-def, resource
    event-bus.once "workflow:start:#{workflow.id}", !(data)->
      # debug "getoeeee!"
      callback error = null, data if callback 
    workflow.act!

  human-execute: !(workflow-def, resource, callback)~> 
    workflow = @add workflow-def, resource
    workflow.act!
    @human-act-step {
      wfid: workflow.id,
      sid: workflow.current-step.id
      sname: workflow.current-step.name
      next-sid: workflow.current-step.next?.id
      next-sname: workflow.current-step.next?.name
    }, callback

  human-act-step: !({wfid, sid}, callback)~>
    step = @get-step wfid, sid
    debug "human-act-step at: #{step.name}"
    if step.next # 不是最后step
      debug "register once on: workflow:waiting-human-on:#{wfid}/#{step.next.id} ", step.next.name
      event-bus.once "workflow:waiting-human-on:#{wfid}/#{step.next.id}", !(data)-> 
        callback error = null, data if callback 
    else #是最后一步
      debug "register once on: workflow:end:#{wfid} "
      event-bus.once "workflow:end:#{wfid}", !(data)->
        callback error = null, data if callback

    debug "emit: wf://#{wfid}/#{sid}/done ", step.name
    event-bus.emit "wf://#{wfid}/#{sid}/done", cc-after-act = {} # 这里需要改进，判断是否处在正确的sid上，和可执行条件

  get-step: (wfid, sid)->
    workflow = @get-workflow-by-id wfid
    for step in _.values workflow.steps
      return step if step.id is sid

  get-all-running-workflow: ->
    @query-workflow -> true

  get-workflow-by-id: (wid)->
    workflows = @query-workflow -> @.id is wid
    workflows[0]

  query-workflow: (query)->
    results = []
    for workflow in @workflows
      results.push workflow if query.apply workflow, null
    results

  _load-config: ->
    # load engine config
    {}

  _event-handler: (e)~>
    # if e.name is 'workflow:creted'
    if (e.name.index-of 'workflow') >= 0
      debug-event e if @config?.debug.workflow is true
      event-bus.emit e.name, e
    else
      debug-event e if @config?.debug.step is true


 