workflow-def = 
  name: 'Hello World'
  can-end: -> true # 结束条件（在step执行后）：this-step.is-end-step or (this-step.next is null and workflow.can-end!)
  steps:
    * name: 'Say Hello'
      # actor: 'auto'
      is-start-active: true
      can-act: -> true
      can-end: -> true
      next: 'Say Hello Back' # null表示是end节点
    * name: 'Say Hello Back'
      # actor: 'auto'
      can-act: -> true
      can-end: -> true
      next: null
