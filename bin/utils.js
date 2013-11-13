(function(){
  var debug, _;
  debug = require('debug')('aw');
  _ = require('underscore');
  module.exports = {
    getUuid: function(){
      return Date.now() + Math.random();
    }
  };
}).call(this);
