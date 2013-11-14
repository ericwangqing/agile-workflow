(function(){
  var debug, _, Actor, AsyncActor, SyncActor, ActorFactory;
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
  AsyncActor = (function(){
    AsyncActor.displayName = 'AsyncActor';
    var prototype = AsyncActor.prototype, constructor = AsyncActor;
    function AsyncActor(){
      this.isDefer = true;
    }
    prototype.act = function(context){};
    return AsyncActor;
  }());
  SyncActor = (function(){
    SyncActor.displayName = 'SyncActor';
    var prototype = SyncActor.prototype, constructor = SyncActor;
    function SyncActor(buinessHandler){
      this.buinessHandler = buinessHandler;
      this.isDefer = false;
    }
    prototype.act = function(context){
      return this.buinessHandler.handle(context);
    };
    return SyncActor;
  }());
  module.exports = ActorFactory = {
    createActor: function(type){
      if (type === 'human' || 'async') {
        return new AsyncActor();
      } else {
        return new SyncActor();
      }
    }
  };
}).call(this);
