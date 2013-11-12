workflow-def = 
  name: 'Hello World'
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
