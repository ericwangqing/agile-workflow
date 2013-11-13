workflow-def = 
  name: '卖苹果，有分支步骤'
  context: {apple: 0, money: 0}
  steps:
    * name: 'Get Apple'
      is-start-active: true
      can-end: -> @stop-get-apple
      next: 
        * name: 'Sale Apple'
          can-enter: -> @apple > 0
        * name: 'Save Money'
          can-enter: -> money > 0

    * name: 'Sale Apple'
      can-act: -> @apple > 0
      can-end: -> @apple = 0
      next: 'Go Home' 

    * name: 'Save Money'
      can-act: -> @money > 0
      can-end: -> @money = 0
      next: 'Go Home' 

    * name: 'Go Home'
      can-act: -> true
      can-end: -> true
