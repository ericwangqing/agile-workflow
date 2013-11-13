(function(){
  var debug, _, Actor, HumanActor, AutoActor, ActorFactory;
  debug = require('debug')('aw');
  _ = require('underscore');
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
    function HumanActor(){
      this.isDefer = true;
    }
    prototype.act = function(context){};
    return HumanActor;
  }());
  AutoActor = (function(){
    AutoActor.displayName = 'AutoActor';
    var prototype = AutoActor.prototype, constructor = AutoActor;
    function AutoActor(buinessHandler){
      this.buinessHandler = buinessHandler;
      this.isDefer = false;
    }
    prototype.act = function(context){
      return this.buinessHandler.handle(context);
    };
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
