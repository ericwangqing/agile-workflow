_ = require 'underscore'

module.exports =
  get-uuid: ->
    Date.now! + Math.random!

