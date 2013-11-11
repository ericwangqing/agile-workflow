engine = null
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
    event-bus.on 'workflow:*:*', !(data)->
      seq++
      # debug "event: ", data.name, seq
      if (data.name.index-of 'workflow:created') is 0
        seq.should.eql 1
      else if (data.name.index-of 'workflow:start') is 0
        seq.should.eql 2
      else if (data.name.index-of 'workflow:acted-on') is 0
        seq.should.within 3, 4
      else if (data.name.index-of 'workflow:end') is 0
        seq.should.eql 5
        done!
    
    debugger
    engine := new Engine store = null, config = debug: workflow: true

    # workflow = engine.execute wfd, resource = null, (error, data)->
      # workflow.act!

    debug '--------------- before human-execute --------------'
    engine.human-execute wfd, resource = null, (error, data)->
      debug '--------------- after human-execute --------------'
      debug '--------------- before human-act-step 1 --------------'
      engine.human-act-step {wfid: data.wfid, sid: data.next-act.id, sname: data.next-act.name}, (error, data)->
        debug '--------------- after human-act-step 1 --------------'
      # console.log "engine, aw:start-workflow, "

    # human-actor-complete-step 'assignment'
    # debug '*** before human submit'
    # human-actor-complete-step 'submit'
    # debug '*** after human submit'


