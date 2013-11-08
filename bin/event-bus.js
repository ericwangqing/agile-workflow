(function(){
  var debug, EventEmitter2, option;
  debug = require('debug')('aw');
  EventEmitter2 = require('eventemitter2').EventEmitter2;
  module.exports = new EventEmitter2(option = {
    wildcard: true,
    delimiter: ':'
  });
}).call(this);
