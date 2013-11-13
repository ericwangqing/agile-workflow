workflow-def = 
  name: '苹果买卖，简单分支2'
  steps:
    * name: 'Start Trade'
      is-start-active: true
      can-end: -> @apple > 0 or @money > 0
      next: 
        * name: 'Sale Apple'
          can-enter: -> @apple > 0 # enter下一个step，则其为active，只有其can-act，才是acting
        * name: 'Save Money'
          can-enter: -> @money > 0

    * name: 'Sale Apple'
      can-act: -> @apple >= 0 # 这里如果仅仅是大于零的话，defer-act会无法进行
      can-end: -> @apple is 0
      next: ['Save Money', 'End Trade']

    * name: 'Save Money'
      can-act: -> @money >= 0
      can-end: -> @money is 0
      next: 'End Trade' 

    * name: 'End Trade'
      can-act: -> true
      can-end: -> @money is 0 and @apple is 0
