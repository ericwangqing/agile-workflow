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
      this.canAct = stepDef.canAct;
      this.canEnd = stepDef.canEnd;
      this.actTimes = 0;
      this.isWaitingDefer = false;
    }
    prototype.setNext = function(next){
      this.next = next;
    };
    prototype.setWorkflow = function(workflow){
      this.workflow = workflow;
    };
    prototype.act = function(){
      debug("act on step: " + this.name);
      if (this.canAct.apply(context)) {
        return this._act();
      } else {
        throw new Error("Can't act on step: " + this.name);
      }
    };
    prototype.deferAct = function(){
      debug("defer act on step: " + this.name);
      if (this.isWaitingDefer) {
        this.actTimes++;
        return this.___act();
      } else {
        return debug("Can't defer-act on when not wait-defer");
      }
    };
    prototype._act = function(){
      var ref$;
      if ((ref$ = this.state) === 'pending' || ref$ === 'done') {
        this.state = 'acting';
      }
      return this.__act();
    };
    prototype.__act = function(){
      var isDefer;
      isDefer = this.actor.act(this.wfId, this.id, this.context);
      if (!isDefer) {
        this.actTimes++;
        return this.___act();
      } else {
        this.isWaitingDefer = true;
        return this;
      }
    };
    prototype.___act = function(){
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
        this.workflow.activeSteps.push(this.next);
        return this.next.act();
      } else {
        return this.workflow.state = 'end';
      }
    };
    prototype.toString = function(){
      return ("Step: '" + this.name + "', state: " + this.state + ", act-times: " + this.actTimes) + (this.isWaitingDefer ? ', is-waiting-defer.' : '.');
    };
    return Step;
  }());
}).call(this);
