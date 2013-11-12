workflow = engine = null
describe '工作流引擎基本测试', ->
  before-each ->
    engine := new Engine store = null

  # can "执行简单工作流: 'Hello World'正常\n", ->
  #   test-workflow 'hello-world', [], ['Say Hello', 'Say Hello Back']

  can "执行有条件的工作流: 'A + B'正常", ->
    test-workflow 'a-plus-b', [{a: 1}, {b: 1}, {c: 2}], ['Get A', 'Get B', 'Judge']

test-workflow = !(wf-name, human-act-results, expected-step-sequence)->
  wfd = utils.load-fixture wf-name
  workflow := engine.human-execute wfd, resource = null
  show-workflow!
  workflow.active-steps[0].name.should.eql expected-step-sequence[0]
  show-active-step!

  for i in [1 to expected-step-sequence.length]
    engine.human-act-step workflow.id, workflow.active-steps[0].name, human-act-results[i - 1]
    if i < expected-step-sequence.length
      workflow.active-steps[0].name.should.eql expected-step-sequence[i]
    else # last step executed
      workflow.active-steps.length.should.eql 0
    show-active-step!

show-active-step = !->
  debug "active-steps: #{workflow.active-steps}"

show-workflow = !->
  debug workflow
