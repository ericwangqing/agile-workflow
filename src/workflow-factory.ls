require! ['./Workflow', './Step', './Actor', './utils']

create-steps = (wid, wfd, resource)->
  steps = create-unwired-steps wid, wfd, resource
  start-step = wire-steps steps, wfd
  [steps, start-step]

create-unwired-steps = (wid, wfd, resource)->
  steps = {}
  for step-def in wfd.steps
    steps[step-def.name] = new Step wid, get-actor!, step-def
  steps


wire-steps = (steps, wfd)->
  for step-def in wfd.steps
    step = steps[step-def.name]
    step.set-next steps[step-def.next]
    start-step = step if step-def.is-start
  start-step

get-actor = (resource)-> #下一步变成resource def
  new Actor!

module.exports = 
  create-workflow: (wfd, resource, engine-callback)->
    wid = 'wf-' + utils.get-uuid!
    [steps, start-step] = create-steps wid, wfd, resource
    start-condition-context = null
    new Workflow wid, wfd.name, steps, start-step, start-condition-context, engine-callback

