human-actor-complete-step = !(step-name)->
  workflow = (engine.query-workflow -> 
    @state is 'start')[0] 

  wid = workflow.id
  sid = workflow.get-step-id-by-name step-name
  event-bus.emit "wf://#{wid}/#{sid}/done", cc-after-act = {}

describe '工作流引擎基本测试', ->
  can '工程测试', ->
    wfd = utils.load-fixture 'workflow-def'
    # debug 'wfd: ', wfd
    debugger
    engine.add wfd .start!
    human-actor-complete-step 'assignment'
    human-actor-complete-step 'submit'

