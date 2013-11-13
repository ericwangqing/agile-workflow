workflow-def = 
  name: '老师给多个同学布置作业（预定义Step条件）'
  context:
    is-all-submit: -> 
      @students.length is 0
    can-submit: ->
      return false if not (@name in @students)
      @students = _.without @students, @name
      true
  steps:
    * name: 'assignment'
      is-start-active: true
      next: 'submit'
    * name: 'submit'
      can-act: -> @can-submit!
      can-end: -> @is-all-submit! # 大家都交了才能结束
