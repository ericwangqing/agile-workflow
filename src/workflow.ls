require! ['./Step', './guard']
_ = require 'underscore'


module.exports = class Workflow extends Step # 这样workflow就可以作为step使用
  @marshal = (workflow)->
    marshalled-workflow = _.pick workflow, 'name', 'state', 'context', 'wfDef'
    marshalled-workflow._id = workflow.id
    guard.stringify-workflow-def-guards marshalled-workflow.wf-def
    marshalled-workflow.steps = [step.marshal! for step in _.values workflow.steps]
    marshalled-workflow

  @unmarshal = (marshalled-workflow)-> 
    guard.restore-workflow-def-guards marshalled-workflow.wf-def

  ({@id, @steps, @context, @wf-def})-> # 这里带上wf-def，以便持久化
    @state = 'pending'
    @name = @wf-def.name
    @can-act = @wf-def.can-act or -> true
    @can-end = @wf-def.can-end or -> true

  human-do: (step-name, human-act-result)->
    @steps[step-name].defer-act human-act-result

  retry-context-aware-steps: ->
    for step in @context-aware-steps!
      if step.state not in ['end', 'acting'] and step.can-act.apply step.context
        step.state = 'active'
        step.act!

  context-aware-steps: ->
    [step for step in _.values @steps when step.is-context-aware]
  
  acting-steps: ->
    [step for step in _.values @steps when step.state is 'acting']

  active-steps: ->
    [step for step in _.values @steps when step.state is 'active']

  active-and-acting-steps: ->
    [step for step in _.values @steps when step.state in ['active', 'acting']]


  is-going-to-end: (step)->
    !!step.is-end-step or (!step.next and @can-end!)

  save: (done)->
    @store.save-workflow @, done

  to-string: ->
    steps-strs = '\n\t' + ([''+ step for step in _.values @steps].join '\n\t') + '\n'
    "Workflow: '#{@name}', id: #{@id}, Steps: #{steps-strs}"

  show-step-in-state: !(state)->
    steps = @[state+'Steps']!
    debug "#{state}-steps: #{steps}"


