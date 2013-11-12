require! ['./Workflow', './Step', './Actor-factory', './utils']
_ = require 'underscore'

create-steps = (wf-def, resource)->
  steps = create-unwired-steps wf-def, resource
  active-steps = wire-steps steps, wf-def
  {steps, active-steps}

create-unwired-steps = (wf-def, resource)->
  steps = {}
  context = utils.deep-copy wf-def.context
  for step-def in wf-def.steps
    actor = get-actor step-def.actor, resource
    steps[step-def.name] = new Step {actor, context: context, step-def}
  steps

wire-steps = (steps, wf-def)->
  active-steps = []
  for step-def in wf-def.steps
    step = steps[step-def.name]
    step.set-next steps[step-def.next]
    active-steps.push step if step-def.is-start-active
  active-steps

get-actor = (type, resource)-> #下一步变成resource def
  Actor-factory.create-actor (type or 'human') #目前默认human

module.exports = 
  create-workflow: (wf-def, resource, engine-callback)->
    {steps, active-steps} = create-steps wf-def, resource
    context = null # 今后这里应该从wf-def中获得 
    id = 'wf-' + utils.get-uuid!
    workflow = new Workflow {id, name: wf-def.name, steps, active-steps, context, engine-callback}
    [step.set-workflow workflow for step in _.values steps]
    workflow

