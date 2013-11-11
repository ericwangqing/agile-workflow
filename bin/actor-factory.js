(function(){
  var debug, eventBus, Actor, HumanActor, AutoActor, ActorFactory;
  debug = require('debug')('aw');
  eventBus = require('./event-bus');
  Actor = (function(){
    Actor.displayName = 'Actor';
    var prototype = Actor.prototype, constructor = Actor;
    function Actor(name){
      this.name = name;
    }
    return Actor;
  }());
  HumanActor = (function(){
    HumanActor.displayName = 'HumanActor';
    var prototype = HumanActor.prototype, constructor = HumanActor;
    prototype.act = function(wfId, sId, done){
      return this._waitHumanWork(wfId, sId, done);
    };
    prototype._waitHumanWork = function(wfId, sId, done){
      return eventBus.once("wf://" + wfId + "/" + sId + "/done", done);
    };
    function HumanActor(){}
    return HumanActor;
  }());
  AutoActor = (function(){
    AutoActor.displayName = 'AutoActor';
    var prototype = AutoActor.prototype, constructor = AutoActor;
    prototype.act = function(wfId, sId, done){
      return this._callAutoTask(wfId, sId, done);
    };
    prototype._callAutoTask = function(wfId, sId, done){
      return done();
    };
    function AutoActor(){}
    return AutoActor;
  }());
  module.exports = ActorFactory = {
    createActor: function(type){
      if (type === 'human') {
        return new HumanActor();
      } else {
        return new AutoActor();
      }
    }
  };
}).call(this);
