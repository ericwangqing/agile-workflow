require! ['./workflow-factory', './event-bus']

workflow-store =
  retrieve-all-running-workflows: -> []

print-event = !(e)->
  step-message = if e.step-name then " step: #{e.step-name}," else ""
  message = "#{e.name},#{step-message} workflow-state: #{e.wf-current-state}"
  console.log message


module.exports =
  workflows: []
  event-handler: (e)->
    # if e.name is 'workflow:creted'
    print-event e if (e.name.index-of 'workflow') < 0

  add: (workflow-def, resource)-> #
    @workflows.push workflow-factory.create-workflow workflow-def, resource, @event-handler
    @

  start: !->
    @workflows.concat workflow-store.retrieve-all-running-workflows!
    [workflow.start! for workflow in @workflows]
    @


  get-all-running-workflow: ->
    @query-workflow -> true

  query-workflow: (query)->
    results = []
    for workflow in @workflows
      results.push workflow if query.apply workflow, null
    results

 