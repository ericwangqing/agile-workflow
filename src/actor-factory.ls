_ = require 'underscore'

class Actor
  (@name)->

class Human-actor
  ->
    @is-defer = true

  act: (context)->
    # do nothing business. all business has already done by human.

class Auto-actor
  (@buiness-handler)->
    @is-defer = false


  act: (context)->
    # do something on context, the business logic should carry on here!
    @buiness-handler.handle context # 注意：将来为了集成Web Service，要改造为异步方法


module.exports = Actor-factory =
  create-actor: (type)->
    if type is 'human' then new Human-actor! else new Auto-actor!
