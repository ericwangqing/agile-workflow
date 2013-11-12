_ = require 'underscore'

module.exports =
  get-uuid: ->
    Date.now! + Math.random!

  deep-copy: (obj)->
    # copy = if obj then JSON.parse JSON.stringify obj else {}
    _.extend {}, obj # for functions

