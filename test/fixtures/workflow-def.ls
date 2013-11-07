workflow-def = 
  id: 'wfd1'
  name: 'homework'
  steps:
    * name: 'assignment'
      is-start: true
      can-start: -> true
      can-end: -> true
      next: 'submit' # null表示是end节点
    * name: 'submit'
      can-start: -> true
      can-end: -> true
      next: null
