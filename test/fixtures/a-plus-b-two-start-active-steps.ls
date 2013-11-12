workflow-def =
  name: 'A + B = C （同时开始AB）'
  context: {a: 0, b: 0, c: 10}
  steps:
    * name: 'Get A'
      is-start-active: true
      can-end: -> @a > 0
      next: 'Judge'
    * name: 'Get B'
      is-start-active: true
      can-end: -> @b > 0
      next: 'Judge'
    * name: 'Judge'
      can-act: -> @a > 0 && @b > 0
      can-end: -> @a + @b == @c


