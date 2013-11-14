# h = require './test-helpers'

# describe '工作流引擎基本测试', ->
#   before-each ->
#     h.extend-should!

#   describe 'Hello World', ->
#     can "正常执行简单工作流: 'Hello World'\n", ->
#       h.test-workflow 'hello-world', [], ['Say Hello', 'Say Hello Back']

#     can "不能执行非Active的步骤\n", ->
#       h.load-workflow 'hello-world'
#       (->
#         h.human-do 'Say Hello Back'
#       ).should.throw!

#   describe "Step有完成条件的工作流", ->
#     can "'A + B = C'一次顺序执行，每个Step执行一次，就满足了can-end\n", ->
#       h.test-workflow 'a-plus-b', [{a: 1}, {b: 1}, {c: 2}], ['Get A', 'Get B', 'Judge']

#     can "'A + B = C'有Step执行多次方满足了can-end\n", ->
#       h.test-workflow 'a-plus-b', [{a: 1}, {b: 0}, {b: 1}, {c: 2}], ['Get A', 'Get B', 'Get B', 'Judge']


