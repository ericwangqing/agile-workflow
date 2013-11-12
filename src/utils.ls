module.exports =
  get-uuid: ->
    Date.now! + Math.random!

  deep-copy: (obj)->
    if obj then JSON.parse JSON.stringify obj else {}

