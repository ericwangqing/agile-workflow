require! ['./Workflow', './Step', './Actor-factory', './utils']
_ = require 'underscore'

create-steps = (wf-def, context, resource)->
  steps = create-unwired-steps wf-def, context, resource
  wire-steps steps, wf-def
  steps

create-unwired-steps = (wf-def, context, resource)->
  steps = {}
  for step-def in wf-def.steps
    actor = get-actor step-def.actor, resource
    steps[step-def.name] = new Step {actor, context, step-def}
  steps

wire-steps = (steps, wf-def)->
  for step-def in wf-def.steps
    step = steps[step-def.name]
    step.set-next steps[step-def.next]
    # step.state = 'active' if step-def.is-start-active


get-actor = (type, resource)-> #下一步变成resource def
  Actor-factory.create-actor (type or 'human') #目前默认human

module.exports = 
  create-workflow: (wf-def, resource, engine-callback)->
    context = _.extend {},  wf-def.context
    steps = create-steps wf-def, context, resource
    id = 'wf-' + utils.get-uuid!
    workflow = new Workflow {id, steps, context, engine-callback} <<< wf-def{name, can-act, can-end}
    [step.set-workflow workflow for step in _.values steps]
    workflow

