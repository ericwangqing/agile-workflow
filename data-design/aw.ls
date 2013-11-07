# 只描述wf，并不保证语义正确。今后再用Petri Net来interpret并分析语义正确性
step-def =
  id: 'step-def-id'
  name: 'step-name'
  description: 'step description'
  type: # start | end | middle | stop
  repeatable: # true | flase
  data-factory: -> # 从context取回step需要的数据
  condition-varibales: [] # 'variable1', 'variable2'
  can-start: -> # 
  can-end: -> # 
  is-repeatable: ->
  execute: ->
  trans-defs: [] # trans-def

step =
  # pre给step输入数据，条件满足时，执行execute
  # class
  # instance
  id: 'step-id'
  type: 'step-def-id'
  status: # pending | waiting | executing | done # 允许step重进入，有可能死循环，需要人工判断中止循环
  conditions: {}# 
  data: {}
  transes:

    # 对next的数据操作

trans-def = 
  id: 'trans-id'
  name: '操作名'
  description: '描述'
  actor-types: # 执行者类型 human | auto
  done: （data)-> # actor执行完成后，通过此回调回传数据 
  nexts:
    * sdid: # next-step-def-id1

workflow-def =
  id: 'workflow-def-id'
  name: 'workflow-name'
  description: 'workflow description'
  step-defs: []
  start: ->
  end: ->
  state-change-callback: (event, data)->

workflow =
  id: 'workflow-id'
  type: 'workflow-def-id'
  status: # pending | waiting | executing | done
  steps: []
  context: # context-data

aw-engine =

