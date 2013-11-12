require! './Step'
_ = require 'underscore'

module.exports = class Workflow extends Step # 这样workflow就可以作为step使用
  ({@id, @name, @steps, @active-steps, @context, @engine-callback})->
    @state = 'pending'

  to-string: ->
    steps-strs = '\n\t' + ([''+ step for step in _.values @steps].join '\n\t') + '\n'
    "Workflow: '#{@name}', id: #{@id}, Steps: #{steps-strs}"

    # @_callback-engine name: "workflow:created:#{@id}"


