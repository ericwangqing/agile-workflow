require! {should, async, _: underscore, './utils', '../bin/Engine'}
debug = require('debug')('aw')

module.exports = 

  create-engine: (done)->
    new Engine db = null, !(@engine)~>
      utils.clean-db done


  load-workflow: (wf-name)->
    wfd = utils.load-fixture wf-name
    @workflow = @engine.human-start wfd, resource = null
    @show-workflow!

  show-acting-step: !->
    @workflow.show-step-in-state 'acting'

  show-active-step: !->
    @workflow.show-step-in-state 'active'


  show-workflow: !->
    debug @workflow

  human-do: (step-name, human-act-result)->
    @engine.human-act-step @workflow.id, step-name, human-act-result

  acting-steps-should-be: (steps)->
    @_steps-in-the-state-should-be steps, 'acting'

  active-steps-should-be: (steps)->
    @_steps-in-the-state-should-be steps, 'active'

  active-and-acting-steps-should-be: (steps)->
    @_steps-in-the-state-should-be steps, 'activeAndActing'

  _steps-in-the-state-should-be: (steps, state)->
    steps = [] <<< 0: steps if not _.is-array steps
    [step.name for step in @workflow.[state + 'Steps']!].should.eql steps


  extend-should: !->
    should.Assertion.prototype.in-acting-steps = ->
      is-in-acting-steps = ~> 
        for step in @workflow.acting-steps!
          return true if @.obj is step.name
        false
      @assert(is-in-acting-steps!, "not in current active steps")

  test-workflow: !(wf-name, human-act-results, expected-step-sequence)->
    @load-workflow wf-name
    @workflow.active-and-acting-steps![0].name.should.eql expected-step-sequence[0]
    @show-active-step!

    for i in [1 to expected-step-sequence.length]
      @human-do @workflow.active-and-acting-steps![0].name, human-act-results[i - 1]
      if i < expected-step-sequence.length
        @active-and-acting-steps-should-be expected-step-sequence[i]
        # expected-step-sequence[i].should.in-acting-steps!
      else # last step executed
        @workflow.active-steps!.length.should.eql 0
        @workflow.acting-steps!.length.should.eql 0
      @show-acting-step! 

