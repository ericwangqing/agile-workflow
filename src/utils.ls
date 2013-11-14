_ = require 'underscore'

_iterate = (obj, visitor)->
  for k, v of obj
    is-going-deep = visitor k, obj[k], obj if obj.hasOwnProperty k
    _iterate obj[k], visitor if _.is-object obj[k] and is-going-deep 

module.exports =
  get-uuid: ->
    Date.now! + Math.random!

  iterate: _iterate

