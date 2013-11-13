require! './Step'
_ = require 'underscore'

module.exports = class Workflow extends Step # 这样workflow就可以作为step使用
  ({@id, @name, @steps, @context, @engine-callback, @can-act = -> true, @can-end = -> true})->
    @state = 'pending'

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

  to-string: ->
    steps-strs = '\n\t' + ([''+ step for step in _.values @steps].join '\n\t') + '\n'
    "Workflow: '#{@name}', id: #{@id}, Steps: #{steps-strs}"

  show-step-in-state: !(state)->
    steps = @[state+'Steps']!
    debug: "#{state}-steps: #{steps}"


    # @_callback-engine name: "workflow:created:#{@id}"


