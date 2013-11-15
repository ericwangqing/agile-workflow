h = require './test-helpers'

describe '持久化测试', ->
  before-each !(done)->
    h.extend-should!
    h.create-engine done

  describe "多个start active step的工作流", (done)->
    can "执行两个start active的工作流: 'A + B = C （同时开始AB）'正常\n", (done)->
      <-! h.load-workflow  'a-plus-b-two-start-active-steps'
      h.active-steps-should-be ['Get A', 'Get B']

      h.human-do 'Get A', {a: 2}
      h.active-steps-should-be ['Get B', 'Judge']

      # TODO: 清空engine，重持久化读入，能够恢复执行
      wfid = h.workflow.id
      debug "------ to persist workflow: #{h.workflow}"
      <-! h.destory-current-engine
      debug "------ workflow when engine destoried: #{h.workflow}, wfid: #wfid"
      <-! h.recreate-engine-and-resume-workflow wfid
      debug "------ resumed workflow: #{h.workflow}"
      
      h.human-do 'Get B', {b: 3}
      h.active-steps-should-be ['Judge']
      done!
