require! './utils'

restore-workflow-def-guards = (wf-def)->
  utils.iterate wf-def, (key, value, obj)->
    if is-guard-key key then parse-guard-function obj, key, value else true

is-guard-key = (key)->
  # workflow definition里所有的条件（guard）均以can开头，例如：can-act, can-end, can-enter
  # 同时，要避免在context里有can-xxx的属性
  (key.index-of 'can') >= 0 and (key.index-of 'context') is -1

parse-guard-function = (obj, key, value)->
  obj[key] = eval "fn = " + value
  is-iterate-deep = false

stringify-workflow-def-guards = (wf-def)->
  utils.iterate wf-def, (key, value, obj)->
    if is-guard-key key then stringify-guard-function obj, key, value else true

stringify-guard-function = (obj, key, value)->
  # debug "[[[[[[[[[[[************** stringfy]]]]]]]]]]]: #obj #key #value"
  obj[key] = value.to-string!
  is-iterate-deep = false 



module.exports = {restore-workflow-def-guards, stringify-workflow-def-guards}