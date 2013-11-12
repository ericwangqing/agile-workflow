workflow-def = 
  name: '买卖苹果，有分支步骤'
  context: {apple: 0, money: 0}
  steps:
    * name: 'Get Apple'
      is-start-active: true
      can-act: -> true
      can-end: -> true
      next: 
        * name: 'Sale Apple'
          can-do: -> @apple > 0
        * name: 'Save Money'
          can-do: -> money > 0

    * name: 'Sale Apple'
      can-act: -> true
      can-end: -> @is-all-submit! # 大家都交了才能结束

    * name: 'Go Home'
      can-act: -> true
      can-end: -> true
