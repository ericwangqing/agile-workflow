workflow-def = 
  name: '老师给多个同学布置作业（动态Step条件）'
  steps:
    * name: 'assignment'
      is-start-active: true
      can-end: -> !!@is-all-submit && !!@can-submit # 给出了判断是否可提交，和大家都提交了的方法
      next: 'submit'
    * name: 'submit'
      can-act: -> @can-submit!
      can-end: -> @is-all-submit! # 大家都交了才能结束
