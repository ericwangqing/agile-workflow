require! ['./Step', './utils']
_ = require 'underscore'

restore-workflow-def-guards = (wf-def)->
  utils.iterate wf-def, (key, value, obj)->
    if is-guard-key key then parse-guard-function obj, key, value else true

is-guard-key = (key)->
  # workflow definition里所有的条件（guard）均以can开头，例如：can-act, can-end, can-enter
  # 同时，要避免在context里有can-xxx的属性
  (key.index-of 'can') >= 0 and (key.index-of 'context') is -1

parse-guard-function = (obj, key, value)->
  obj[key] = eval "fn = " + value
  is-iterate-deep = false

stringify-workflow-def-guards = (wf-def)->
  utils.iterate wf-def, (key, value, obj)->
    if is-guard-key key then stringify-guard-function obj, key, value else true

stringify-guard-function = (obj, key, value)->
  # debug "[[[[[[[[[[[************** stringfy]]]]]]]]]]]: #obj #key #value"
  obj[key] = value.to-string!
  is-iterate-deep = false 


module.exports = class Workflow extends Step # 这样workflow就可以作为step使用
  @marshal = (workflow)->
    marshalled-workflow = _.pick workflow, 'name', 'id', 'state', 'context', 'wfDef'
    stringify-workflow-def-guards marshalled-workflow.wf-def
    marshalled-workflow.steps = [step.marshal! for step in _.values workflow.steps]
    marshalled-workflow

  @unmarshal = (marshalled-workflow)-> 
    restore-workflow-def-guards marshalled-workflow.wf-def

  ({@id, @steps, @context, @wf-def})-> # 这里带上wf-def，以便持久化
    @state = 'pending'
    @name = @wf-def.name
    @can-act = @wf-def.can-act or -> true
    @can-end = @wf-def.can-end or -> true

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
    console.log "before workflow save"
    marshalled-workflow = @@marshal @
    debug "marshalled-workflow: ", marshalled-workflow
    @store.save-workflow marshalled-workflow, done

  to-string: ->
    steps-strs = '\n\t' + ([''+ step for step in _.values @steps].join '\n\t') + '\n'
    "Workflow: '#{@name}', id: #{@id}, Steps: #{steps-strs}"

  show-step-in-state: !(state)->
    steps = @[state+'Steps']!
    debug "#{state}-steps: #{steps}"


