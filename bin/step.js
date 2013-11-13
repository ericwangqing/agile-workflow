(function(){
  var debug, utils, _, Step;
  debug = require('debug')('aw');
  utils = require('./utils');
  _ = require('underscore');
  module.exports = Step = (function(){
    Step.displayName = 'Step';
    var prototype = Step.prototype, constructor = Step;
    function Step(arg$){
      var stepDef;
      this.actor = arg$.actor, this.context = arg$.context, stepDef = arg$.stepDef;
      _.extend(this, _.pick(stepDef, 'name', 'is-start-active'));
      this.state = 'pending';
      if (stepDef.isStartActive) {
        this.state = 'active';
      }
      this.canAct = stepDef.canAct || function(){
        return true;
      };
      this.canEnd = stepDef.canEnd || function(){
        return true;
      };
      this.actTimes = 0;
    }
    prototype.setNext = function(next){
      this.next = next;
    };
    prototype.setWorkflow = function(workflow){
      this.workflow = workflow;
    };
    prototype.checkStateActable = function(){
      if (this.workflow.state === 'ended') {
        throw new Error("Can't act on ended workflow");
      }
      if (this.state === 'pending') {
        throw new Error("Can't act on inactive step: " + this.name);
      }
    };
    prototype.act = function(otherContextInfo, toWaitingDefer){
      if (typeof toWaitingDefer === 'undefined') {
        toWaitingDefer = true;
      }
      _.extend(this.context, otherContextInfo);
      this.checkStateActable();
      if (this.canAct.apply(this.context) && !(this.actor.isDefer && toWaitingDefer)) {
        return this._act();
      } else {
        debug("Can't act on step: " + this.name + ", state: " + this.state);
        if (this.actor.isDefer && !toWaitingDefer) {
          throw new Error("Can't defer-act on step: " + this.name + ", state: " + this.state);
        }
      }
    };
    prototype.deferAct = function(otherContextInfo){
      debug("defer-act: " + this);
      return this.act(otherContextInfo, false);
    };
    prototype._act = function(){
      debug("act on step: " + this.name);
      this.workflow.state = 'started';
      this.state = 'acting';
      this.actor.act(this.context);
      this.actTimes++;
      return this._afterAct();
    };
    prototype._afterAct = function(){
      if (this.canEnd.apply(this.context)) {
        this.state = 'done';
      } else {
        debug("Still in step: " + this.name + ", act times: " + this.actTimes);
        this.act();
      }
      if (this._ifCanEnterNext()) {
        return this._actNext();
      }
    };
    prototype._ifCanEnterNext = function(){
      return this.canEnd.apply(this.context);
    };
    prototype._actNext = function(){
      if (this.workflow.isGoingToEnd(this)) {
        return this.workflow.state = 'ended';
      } else {
        this.next.state = 'active';
        return this.next.act();
      }
    };
    prototype.toString = function(){
      return "Step: '" + this.name + "', state: " + this.state + ", act-times: " + this.actTimes + ".";
    };
    return Step;
  }());
}).call(this);
