h = require './test-helpers'

describe '复杂工作流测试', ->
  before-each !(done)->
    h.extend-should!
    h.create-engine done

  describe "next有分支的工作流", ->
    can "正常执行'苹果买卖'，选择'Sale Apple'\n", !(done)->
      <-! h.load-workflow  'apple-split-steps'
      h.active-steps-should-be ['Start Trade']

      h.human-do 'Start Trade', apple: 10
      h.active-steps-should-be ['Sale Apple']
      h.acting-steps-should-be []

      h.human-do 'Sale Apple', apple: 0, money: 0
      h.active-steps-should-be ['End Trade']
      h.acting-steps-should-be []

      h.human-do 'End Trade'
      h.active-and-acting-steps-should-be []
      done!

    can "正常执行有分支的简单'苹果买卖'，选择'Save Money'\n", !(done)->
      <-! h.load-workflow  'apple-split-steps'
      h.active-steps-should-be ['Start Trade']

      h.human-do 'Start Trade', money: 10
      h.active-steps-should-be ['Save Money']
      h.acting-steps-should-be []

      h.human-do 'Save Money', money: 0, apple: 0
      h.active-steps-should-be ['End Trade']
      h.acting-steps-should-be []

      h.human-do 'End Trade'
      h.active-and-acting-steps-should-be []
      done!

    can "正常执行有分支的简单'苹果买卖2'，选择'Sale Apple'\n", !(done)->
      <-! h.load-workflow  'apple-split-steps-2'
      h.active-steps-should-be ['Start Trade']

      h.human-do 'Start Trade', apple: 10
      h.active-steps-should-be ['Sale Apple']
      h.acting-steps-should-be []

      h.human-do 'Sale Apple', apple: 0, money: 0
      h.active-steps-should-be ['Save Money', 'End Trade']
      h.acting-steps-should-be []

      h.human-do 'End Trade'
      h.active-steps-should-be ['Save Money']
      done!

    can "正常执行有分支的简单'苹果买卖2'，选择'Save Money'\n", !(done)->
      <-! h.load-workflow  'apple-split-steps-2'
      h.active-steps-should-be ['Start Trade']

      h.human-do 'Start Trade', money: 10
      h.active-steps-should-be ['Save Money']
      h.acting-steps-should-be []

      h.human-do 'Save Money', money: 0, apple: 0
      h.active-steps-should-be ['End Trade']
      h.acting-steps-should-be []

      h.human-do 'End Trade'
      h.active-steps-should-be []
      done!

  describe "context-aware step, 在context变化后, 自动评估是否act", ->

    can "正常执行有分支的context aware'苹果买卖3'，选择'Sale Apple'\n", !(done)->
      <-! h.load-workflow  'apple-split-steps-context-aware'
      h.active-steps-should-be ['Start Trade']

      h.human-do 'Start Trade', apple: 10
      h.active-steps-should-be ['Sale Apple']
      h.acting-steps-should-be []

      h.human-do 'Sale Apple', {apple: 0, money: 10}
      h.active-steps-should-be ['Save Money', 'End Trade']
      h.acting-steps-should-be []

      h.human-do 'End Trade'
      h.active-steps-should-be ['Save Money']
      done!

    can "正常执行有分支的context aware'苹果买卖3'，选择'Save Money'\n", !(done)->
      <-! h.load-workflow  'apple-split-steps-2'
      h.active-steps-should-be ['Start Trade']

      h.human-do 'Start Trade', money: 10
      h.active-steps-should-be ['Save Money']
      h.acting-steps-should-be []

      h.human-do 'Save Money', money: 0, apple: 0
      h.active-steps-should-be ['End Trade']
      h.acting-steps-should-be []

      h.human-do 'End Trade'
      h.active-steps-should-be []
      done!


# 在can-act、can-end、can-enter等条件中查询workflow的状态信息，进行判断