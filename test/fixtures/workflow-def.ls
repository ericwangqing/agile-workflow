workflow-def = 
  id: 'wfd1'
  name: 'homework'
  steps:
    * name: 'assignment'
      actor: 'auto'
      is-start: true
      can-act: -> true
      can-end: -> true
      next: 'submit' # null表示是end节点
    * name: 'submit'
      actor: 'auto'
      can-act: -> true
      can-end: -> true
      next: null
