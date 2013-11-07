human-actor-complete-step = !(step-name, done)->
  workflow = (engine.query-workflow -> 
    @state is 'start')[0] 

  wid = workflow.id
  sid = workflow.get-step-id-by-name step-name
  event-bus.emit "wf://#{wid}/#{sid}/done", cc-after-act = {}

describe '工作流引擎基本测试', ->
  can '引擎正常执行简单工作流', (done)->
    seq = 0
    wfd = utils.load-fixture 'workflow-def'
    # debug 'wfd: ', wfd
    event-bus.on 'workflow:*', !(data)->
      seq++
      if data.name is 'workflow:created'
        seq.should.eql 1
      else if data.name is 'workflow:start'
        seq.should.eql 2
      else if data.name is 'workflow:end'
        seq.should.eql 3
        done!
    
    debugger
    engine.add wfd .start!

    human-actor-complete-step 'assignment'
    human-actor-complete-step 'submit'

