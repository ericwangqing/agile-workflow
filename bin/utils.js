(function(){
  var debug, _, _iterate;
  debug = require('debug')('aw');
  _ = require('underscore');
  _iterate = function(obj, visitor){
    var k, v, isGoingDeep, results$ = [];
    for (k in obj) {
      v = obj[k];
      if (obj.hasOwnProperty(k)) {
        isGoingDeep = visitor(k, obj[k], obj);
      }
      if (_.isObject(obj[k]) && isGoingDeep) {
        results$.push(_iterate(obj[k], visitor));
      }
    }
    return results$;
  };
  module.exports = {
    getUuid: function(){
      return Date.now() + Math.random();
    },
    iterate: _iterate
  };
}).call(this);
