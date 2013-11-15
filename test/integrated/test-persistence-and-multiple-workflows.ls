  # ！！！共享头部，下面必须缩进 ！！！
  describe "持久化测试", ->
    describe "中断后重新读取并恢复执行工作流", (done)->
      can "中断后重新读取并恢复执行工作流: 'A + B = C （同时开始AB）'正常\n", (done)->
        (w) <-! h.load-workflow  'a-plus-b-two-start-active-steps'
        w.active-steps-should-be ['Get A', 'Get B']

        w.human-do 'Get A', {a: 2}
        w.active-steps-should-be ['Get B', 'Judge']

        # TODO: 清空engine，重持久化读入，能够恢复执行
        wfid = w.id
        # debug "------ to persist workflow: #{w}"
        <-! h.destory-current-engine  
        # debug "------ workflow when engine destoried: #{w}, wfid: #wfid"
        (w) <-! h.recreate-engine-and-resume-workflow wfid
        # debug "------ resumed workflow: #{w}"
        
        w.human-do 'Get B', {b: 3}
        w.active-steps-should-be ['Judge']
        done!


    describe "多个工作流同时进行正常", (done)-> 
      can "同时执行工作流: 'A + B = C （同时开始AB）'和'苹果买卖'正常\n", (done)->
        (plus) <-! h.load-workflow  'a-plus-b-two-start-active-steps'
        (apple) <-! h.load-workflow  'apple-split-steps'
        plus.active-steps-should-be ['Get A', 'Get B']
        apple.active-steps-should-be ['Start Trade']

        plus.human-do 'Get A', {a: 2}
        plus.active-steps-should-be ['Get B', 'Judge']

        apple.human-do 'Start Trade', apple: 10
        apple.active-steps-should-be ['Sale Apple']
        apple.acting-steps-should-be []

        plus.human-do 'Get B', {b: 3}
        plus.active-steps-should-be ['Judge']

        apple.human-do 'Sale Apple', apple: 0, money: 0
        apple.active-steps-should-be ['End Trade']
        apple.acting-steps-should-be []

        plus.human-do 'Judge', {c: 5}
        plus.active-and-acting-steps-should-be []

        apple.human-do 'End Trade'
        apple.active-and-acting-steps-should-be []
        done!

    describe "多个工作流中断后重新读取正常恢复执行", (done)->
      can "同时执行工作流: 'A + B = C （同时开始AB）'和'苹果买卖'正常\n", (done)->
        (plus) <-! h.load-workflow  'a-plus-b-two-start-active-steps'
        (apple) <-! h.load-workflow  'apple-split-steps'
        plus.active-steps-should-be ['Get A', 'Get B']
        apple.active-steps-should-be ['Start Trade']

        plus.human-do 'Get A', {a: 2}
        plus.active-steps-should-be ['Get B', 'Judge']

        apple.human-do 'Start Trade', apple: 10
        apple.active-steps-should-be ['Sale Apple']
        apple.acting-steps-should-be []

        # TODO: 清空engine，重持久化读入，能够恢复执行
        apple-id = apple.id
        plus-id = plus.id
        # debug "------ to persist workflow: #{w}"
        <-! h.destory-current-engine
        # debug "------ workflow when engine destoried"
        (workflows) <-! h.recreate-engine-and-resume-workflows [apple-id, plus-id]
        # debug "------ resumed workflow"
        plus = workflows[plus-id]
        apple = workflows[apple-id]

        plus.human-do 'Get B', {b: 3}
        plus.active-steps-should-be ['Judge']

        apple.human-do 'Sale Apple', apple: 0, money: 0
        apple.active-steps-should-be ['End Trade']
        apple.acting-steps-should-be []

        debug "plus context: ", plus.context
        plus.human-do 'Judge', {c: 5}
        plus.active-and-acting-steps-should-be []

        apple.human-do 'End Trade'
        apple.active-and-acting-steps-should-be []
        done! 
