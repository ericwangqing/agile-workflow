require! ['./Workflow', './Step', './Actor-factory', './utils']
_ = require 'underscore'

create-steps = (wf-def, context, marshalled-workflow)->
  steps = create-unwired-steps wf-def, context, marshalled-workflow
  wire-steps steps, wf-def
  steps

create-unwired-steps = (wf-def, context, marshalled-workflow)->
  steps = {}
  for step-def in wf-def.steps
    actor = get-actor step-def.actor
    step = new Step {actor, context, step-def}
    restore-state step, marshalled-workflow if marshalled-workflow
    steps[step-def.name] = step
  steps

restore-state = !(step, marshalled-workflow)->
  for marshalled-step in marshalled-workflow.steps
    if step.name is marshalled-step.name
      step.state = marshalled-step.state
      step.act-times = marshalled-step.act-times

wire-steps = (steps, wf-def)->
  for step-def in wf-def.steps
    step = steps[step-def.name]
    if typeof step-def.next is 'string'
      next-steps = [] <<< 0: step: steps[step-def.next]
    else if _.is-array step-def.next
      next-steps = _get-next-steps steps, step-def.next
    step.next = next-steps

_get-next-steps = (steps, next-def)->
  create-step = (s)->
    if typeof s is "string" then {step: steps[s]} else {step: steps[s.name], can-enter: s.can-enter}
  [create-step s for s in next-def]

get-actor = (type)-> #下一步变成resource def
  Actor-factory.create-actor (type or 'human') #目前默认human

module.exports = 
  create-workflow: (wf-def, marshalled-workflow)->
    context = _.extend {},  (marshalled-workflow?.context or wf-def.context)
    steps = create-steps wf-def, context, marshalled-workflow
    id = 'wf-' + utils.get-uuid!
    workflow = new Workflow {id, steps, context, wf-def}
    [step.workflow = workflow for step in _.values steps]
    workflow



