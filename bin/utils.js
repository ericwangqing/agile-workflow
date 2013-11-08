(function(){
  var debug;
  debug = require('debug')('aw');
  module.exports = {
    getUuid: function(){
      return Date.now() + Math.random();
    }
  };
}).call(this);
