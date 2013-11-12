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
      _.extend(this, _.pick(stepDef, 'name', 'is-start'));
      this.state = 'pending';
      this.canAct = stepDef.canAct || function(){
        return true;
      };
      this.canEnd = stepDef.canEnd || function(){
        return true;
      };
      this.actTimes = 0;
      this.isWaitingDefer = false;
    }
    prototype.setNext = function(next){
      this.next = next;
    };
    prototype.setWorkflow = function(workflow){
      this.workflow = workflow;
    };
    prototype.checkActable = function(){
      var ref$;
      if (this.workflow.state === 'ended') {
        throw new Error("Can't act on ended workflow");
      }
      if (!((ref$ = this.state) === 'active' || ref$ === 'acting')) {
        throw new Error("Can't act on inactive step: " + this.name);
      }
    };
    prototype.act = function(){
      this.checkActable();
      if (this.actor.isDefer) {
        debug("wait on defer act: " + this.name);
        return this.isWaitingDefer = true;
      } else if (this.canAct.apply(this.context)) {
        return this._act();
      } else {
        return debug("Can't act on step: " + this.name + ", state: " + this.state);
      }
    };
    prototype.deferAct = function(humanActResult){
      var canAct;
      this.checkActable();
      debug("defer act on step: " + this.name);
      this.context = _.extend(this.context, humanActResult);
      if (this.isWaitingDefer && (canAct = this.canAct.apply(this.context))) {
        this.isWaitingDefer = false;
        return this._act();
      } else {
        return debug("Can't defer-act. is-waiting-defer: " + isWaitingDefer + ", can-act: " + canAct + " ");
      }
    };
    prototype._act = function(){
      var ref$;
      debug("act on step: " + this.name);
      this.workflow.state = 'started';
      this.actTimes++;
      if ((ref$ = this.state) === 'pending' || ref$ === 'active' || ref$ === 'done') {
        this.state = 'acting';
      }
      return this.__act();
    };
    prototype.__act = function(){
      if (this.canEnd.apply(this.context)) {
        this.state = 'done';
        this.workflow.activeSteps = _.without(this.workflow.activeSteps, this);
        return this._actNext();
      } else {
        debug("Still in step: " + this.name + ", act times: " + this.actTimes);
        return this.act();
      }
    };
    prototype._actNext = function(){
      if (this.next) {
        this.next.state = 'active';
        this.workflow.activeSteps.push(this.next);
        this.workflow.activeSteps = _.uniq(this.workflow.activeSteps);
        return this.next.act();
      } else {
        return this.workflow.state = 'ended';
      }
    };
    prototype.toString = function(){
      return ("Step: '" + this.name + "', state: " + this.state + ", act-times: " + this.actTimes) + (this.isWaitingDefer ? ', is-waiting-defer.' : '.');
    };
    return Step;
  }());
}).call(this);
