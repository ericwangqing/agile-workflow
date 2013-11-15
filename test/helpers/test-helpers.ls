require! {should, async, _: underscore, './utils', '../bin/Engine'}
debug = require('debug')('aw')

module.exports = 
  clean-db: !(done)->
    (error, result) <~! @engine.store.collection.remove {} 
    done!

  create-engine: !(done)->
    new Engine db = null, !(@engine)~>
      @engine.start done

  destory-current-engine: !(done)->
    @engine.stop !~>
      @engine = null
      @workflow = null
      # debug "********* engine stop: engine: #{@engine}, workflow: #@workflow"
      done!

  recreate-engine-and-resume-workflow: !(wfid, done)->
    (workflows) <-! @recreate-engine-and-resume-workflows [wfid]
    done workflows[wfid]

  recreate-engine-and-resume-workflows: !(wfids, done)->
    (@engine) <~! new Engine db = null
    <~! @engine.start
    workflows = {}
    if @engine.workflows.length >= wfids.length
      for wfid in wfids
        workflow = @engine.get-workflow-by-id wfid
        @extend-workflow-for-test workflow
        workflows[wfid] = workflow
      # @show-workflow!
      done workflows
    else
      throw new Error "can't get #{wfids} form engine, there are only #{@engine.workflows.length} in engine."

  load-workflow: (wf-name, done)->
    wfd = utils.load-fixture wf-name
    @engine.human-start wfd, !(workflow)~>
      @extend-workflow-for-test workflow
      # workflow.show!
      done workflow

  extend-workflow-for-test: (workflow)->
    _.extend workflow, {
      show-acting-step: !->
        @show-step-in-state 'acting'

      show-active-step: !->
        @show-step-in-state 'active'
     
      show: !->
        debug @

      acting-steps-should-be: (steps)->
        @_steps-in-the-state-should-be steps, 'acting'

      active-steps-should-be: (steps)->
        @_steps-in-the-state-should-be steps, 'active'

      active-and-acting-steps-should-be: (steps)->
        @_steps-in-the-state-should-be steps, 'activeAndActing'

      _steps-in-the-state-should-be: (steps, state)->
        steps = [] <<< 0: steps if not _.is-array steps
        [step.name for step in @[state + 'Steps']!].should.eql steps
    }

  extend-should: !->
    should.Assertion.prototype.in-acting-steps = ->
      is-in-acting-steps = ~> 
        for step in @workflow.acting-steps!
          return true if @.obj is step.name
        false
      @assert(is-in-acting-steps!, "not in current active steps")

  test-workflow: !(wf-name, human-act-results, expected-step-sequence, done)->
    (w) <~! @load-workflow wf-name
    w.active-and-acting-steps![0].name.should.eql expected-step-sequence[0]
    w.show-active-step!

    for i in [1 to expected-step-sequence.length]
      w.human-do w.active-and-acting-steps![0].name, human-act-results[i - 1]
      if i < expected-step-sequence.length
        w.active-and-acting-steps-should-be expected-step-sequence[i]
        # expected-step-sequence[i].should.in-acting-steps!
      else # last step executed
        w.active-steps!.length.should.eql 0
        w.acting-steps!.length.should.eql 0
      w.show-acting-step! 
    done!

