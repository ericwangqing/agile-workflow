h = require './test-helpers'

describe '工作流引擎基本测试', ->
  before-each ->
    h.extend-should!

  describe 'Hello World', ->
    can "执行简单工作流: 'Hello World'正常\n", ->
      h.test-workflow 'hello-world', [], ['Say Hello', 'Say Hello Back']

    can "不能执行非Active的步骤\n", ->
      h.load-workflow 'hello-world'
      (->
        h.human-do 'Say Hello Back'
      ).should.throw!

  describe "Step有完成条件的工作流", ->
    can "'A + B = C'一次顺序执行，每个Step执行一次，就满足了can-end\n", ->
      h.test-workflow 'a-plus-b', [{a: 1}, {b: 1}, {c: 2}], ['Get A', 'Get B', 'Judge']

    can "'A + B = C'有Step执行多次方满足了can-end\n", ->
      h.test-workflow 'a-plus-b', [{a: 1}, {b: 0}, {b: 1}, {c: 2}], ['Get A', 'Get B', 'Get B', 'Judge']



test-homework-workflow = !(workflow-def-filename, initial-context)->
  load-workflow workflow-def-filename
  active-steps-should-be 'assignment'

  human-do 'assignment', initial-context
  active-steps-should-be 'submit'

  human-do 'submit', {name: '张三'}
  active-steps-should-be 'submit'

  (->
    human-do 'submit', {name: '张三'}
  ).should.throw!
  active-steps-should-be 'submit'

  (->
    human-do 'submit', {name: 'Stranger'}
  ).should.throw!
  active-steps-should-be 'submit'

  human-do 'submit', {name: '李四'}
  active-steps-should-be []


