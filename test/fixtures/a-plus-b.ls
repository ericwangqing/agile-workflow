workflow-def =
  name: 'A + B'
  context: {a: 0, b: 0, c: 10}
  steps:
    * name: 'Get A'
      is-start-active: true
      can-end: -> @a > 0
      next: 'Get B'
    * name: 'Get B'
      can-end: -> @b > 0
      next: 'Judge'
    * name: 'Judge'
      can-end: -> @a + @b == @c


