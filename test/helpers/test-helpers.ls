require! {should, async, _: underscore, './utils', '../bin/Engine'}
debug = require('debug')('aw')

module.exports = 

  engine: new Engine store = null

  load-workflow: (wf-name)->
    wfd = utils.load-fixture wf-name
    @workflow = @engine.human-execute wfd, resource = null
    @show-workflow!

  show-active-step: !->
    debug "active-steps: #{@workflow.active-steps}"

  show-workflow: !->
    debug @workflow

  human-do: (step-name, human-act-result)->
    @engine.human-act-step @workflow.id, step-name, human-act-result

  active-steps-should-be: (steps)->
    steps = [] <<< 0: steps if not _.is-array steps
    [step.name for step in @workflow.active-steps].should.eql steps

  extend-should: !->
    should.Assertion.prototype.in-active-steps = ->
      is-in-active-steps = ~> 
        for step in @workflow.active-steps
          return true if @.obj is step.name
        false
      @assert(is-in-active-steps!, "not in current active steps")

  test-workflow: !(wf-name, human-act-results, expected-step-sequence)->
    @load-workflow wf-name
    @workflow.active-steps[0].name.should.eql expected-step-sequence[0]
    @show-active-step!

    for i in [1 to expected-step-sequence.length]
      @human-do @workflow.active-steps[0].name, human-act-results[i - 1]
      if i < expected-step-sequence.length
        @active-steps-should-be expected-step-sequence[i]
        # expected-step-sequence[i].should.in-active-steps!
      else # last step executed
        @workflow.active-steps.length.should.eql 0
      @show-active-step!

