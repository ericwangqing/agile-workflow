  # ！！！共享头部，下面必须缩进 ！！！
  describe '工作流引擎基本测试', ->
    before-each !(done)->
      h.extend-should!
      h.create-engine done

    describe 'Hello World', ->
      can "正常执行简单工作流: 'Hello World'\n", !(done)->
        h.test-workflow 'hello-world', [], ['Say Hello', 'Say Hello Back'], done

      can "不能执行非Active的步骤\n", !(done)->
        (w) <-! h.load-workflow  'hello-world'
        w = h.workflow
        (->
          w.human-do 'Say Hello Back'
        ).should.throw!
        done!

    describe "Step有完成条件的工作流", ->
      can "'A + B = C'一次顺序执行，每个Step执行一次，就满足了can-end\n", !(done)->
        h.test-workflow 'a-plus-b', [{a: 1}, {b: 1}, {c: 2}], ['Get A', 'Get B', 'Judge'], done

      can "'A + B = C'有Step执行多次方满足了can-end\n", !(done)->
        h.test-workflow 'a-plus-b', [{a: 1}, {b: 0}, {b: 1}, {c: 2}], ['Get A', 'Get B', 'Get B', 'Judge'], done


