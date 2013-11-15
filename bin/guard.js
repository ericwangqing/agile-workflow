(function(){
  var debug, utils, restoreWorkflowDefGuards, isGuardKey, parseGuardFunction, stringifyWorkflowDefGuards, stringifyGuardFunction;
  debug = require('debug')('aw');
  utils = require('./utils');
  restoreWorkflowDefGuards = function(wfDef){
    return utils.iterate(wfDef, function(key, value, obj){
      if (isGuardKey(key)) {
        return parseGuardFunction(obj, key, value);
      } else {
        return true;
      }
    });
  };
  isGuardKey = function(key){
    return key.indexOf('can') >= 0 && key.indexOf('context') === -1;
  };
  parseGuardFunction = function(obj, key, value){
    var isIterateDeep;
    obj[key] = eval("fn = " + value);
    return isIterateDeep = false;
  };
  stringifyWorkflowDefGuards = function(wfDef){
    return utils.iterate(wfDef, function(key, value, obj){
      if (isGuardKey(key)) {
        return stringifyGuardFunction(obj, key, value);
      } else {
        return true;
      }
    });
  };
  stringifyGuardFunction = function(obj, key, value){
    var isIterateDeep;
    obj[key] = value.toString();
    return isIterateDeep = false;
  };
  module.exports = {
    restoreWorkflowDefGuards: restoreWorkflowDefGuards,
    stringifyWorkflowDefGuards: stringifyWorkflowDefGuards
  };
}).call(this);
