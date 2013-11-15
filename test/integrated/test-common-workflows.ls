# h = require './test-helpers'

# describe '常规工作流测试', ->
#   before-each !(done)->
#     h.extend-should!
#     h.create-engine done


#   describe "多个start active step的工作流", ->
#     can "执行两个start active的工作流: 'A + B = C （同时开始AB）'正常\n", ->
#       h.load-workflow 'a-plus-b-two-start-active-steps'
#       h.active-steps-should-be ['Get A', 'Get B']

#       h.human-do 'Get A', {a: 2}
#       h.active-steps-should-be ['Get B', 'Judge']
      
#       h.human-do 'Get B', {b: 3}
#       h.active-steps-should-be ['Judge']

#       h.human-do 'Judge', {c: 5}
#       h.active-and-acting-steps-should-be []
 
#   describe "多个Actor同时执行一个step的工作流", ->
#     can "执行多个学生交作业的工作流'Homework（预定义条件）'正常\n", ->
#       test-homework-workflow 'homework-predefined-condition', initial-context = students: ['张三', '李四']

#     can "执行多个学生交作业的工作流'Homework（动态条件）'正常\n", ->
#       test-homework-workflow 'homework-dynamic-condition', initial-context =
#         students: ['张三', '李四']
#         is-all-submit: -> 
#           @students.length is 0
#         can-submit: ->
#           return false if not (@name in @students)
#           @students = _.without @students, @name 


# test-homework-workflow = !(workflow-def-filename, initial-context)->
#   h.load-workflow workflow-def-filename
#   h.active-steps-should-be 'assignment'

#   h.human-do 'assignment', initial-context
#   h.active-steps-should-be 'submit'

#   h.human-do 'submit', {name: '张三'}
#   h.acting-steps-should-be 'submit'

#   (->
#     h.human-do 'submit', {name: '张三'}
#   ).should.throw!
#   h.acting-steps-should-be 'submit'

#   (->
#     h.human-do 'submit', {name: 'Stranger'}
#   ).should.throw!
#   h.acting-steps-should-be 'submit'

#   h.human-do 'submit', {name: '李四'}
#   h.active-and-acting-steps-should-be []

