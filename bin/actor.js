(function(){
  var debug, eventBus, HumanActor;
  debug = require('debug')('aw');
  eventBus = require('./event-bus');
  module.exports = HumanActor = (function(){
    HumanActor.displayName = 'HumanActor';
    var prototype = HumanActor.prototype, constructor = HumanActor;
    prototype.act = function(wfId, sId, done){
      return eventBus.on("wf://" + wfId + "/" + sId + "/done", done);
    };
    function HumanActor(){}
    return HumanActor;
  }());
}).call(this);
