require! ['./Workflow', './Step', './Actor-factory', './utils']
_ = require 'underscore'

create-steps = (wf-def, context)->
  steps = create-unwired-steps wf-def, context
  wire-steps steps, wf-def
  steps

create-unwired-steps = (wf-def, context)->
  steps = {}
  for step-def in wf-def.steps
    actor = get-actor step-def.actor
    step = new Step {actor, context, step-def}
    steps[step-def.name] = step
  steps

restore-steps-state = !(workflow, marshalled-steps)->
  for step in _.values workflow.steps
    restore-step-state step, marshalled-steps 


restore-step-state = !(step, marshalled-steps)->
  for marshalled-step in marshalled-steps
    if marshalled-step.name is step.name 
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

_create-workflow = (wf-def, marshalled-workflow-id)->
  context = _.extend {},  wf-def.context
  steps = create-steps wf-def, context
  id = marshalled-workflow-id or 'wf-' + utils.get-uuid!
  workflow = new Workflow {id, steps, context, wf-def}
  [step.workflow = workflow for step in _.values steps]
  workflow

module.exports = 
  create-workflow: (wf-def)->
    _create-workflow wf-def

  resume-marshalled-workflow: (marshalled-workflow)->
    marshalled-workflow.wf-def.context = marshalled-workflow.context # 恢复context
    workflow = _create-workflow marshalled-workflow.wf-def, marshalled-workflow._id
    restore-steps-state workflow, marshalled-workflow.steps
    workflow




