(function(){
  var debug;
  debug = require('debug')('aw');
  module.exports = {
    getUuid: function(){
      return Date.now() + Math.random();
    },
    deepCopy: function(obj){
      if (obj) {
        return JSON.parse(JSON.stringify(obj));
      } else {
        return {};
      }
    }
  };
}).call(this);
