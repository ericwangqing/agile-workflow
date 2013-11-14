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
      _.extend(this, _.pick(stepDef, 'name', 'isStartActive', 'isContextAware'));
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
      this.workflow.state = 'started';
      this.state = 'acting';
      this.actor.act(this.context);
      this.actTimes++;
      return this._afterAct();
    };
    prototype._afterAct = function(){
      this.workflow.retryContextAwareSteps();
      this._activeNext();
      if (this.canEnd.apply(this.context)) {
        this.state = 'done';
        if (this.workflow.isGoingToEnd(this)) {
          this.workflow.state = 'ended';
        }
        return debug("End step: " + this.name + ", act times: " + this.actTimes + ",  active-steps: " + this.workflow.activeSteps() + ", acting-steps: " + this.workflow.actingSteps());
      } else {
        debug("Still in step: " + this.name + ", act times: " + this.actTimes + ",  active-steps: " + this.workflow.activeSteps() + ", acting-steps: " + this.workflow.actingSteps());
        return this.act();
      }
    };
    prototype._activeNext = function(){
      var i$, ref$, len$, nextStep, results$ = [];
      for (i$ = 0, len$ = (ref$ = this.next).length; i$ < len$; ++i$) {
        nextStep = ref$[i$];
        if ((nextStep.canEnter || this.canEnd).apply(this.context)) {
          nextStep.step.state = 'active';
          results$.push(nextStep.step.act());
        }
      }
      return results$;
    };
    prototype.marshal = function(){
      var marshalledWorkflow;
      return marshalledWorkflow = _.pick(this, 'name', 'state', 'actTimes');
    };
    prototype.toString = function(){
      return "Step: '" + this.name + "', state: " + this.state + ", act-times: " + this.actTimes + ".";
    };
    return Step;
  }());
}).call(this);
