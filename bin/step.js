(function(){
  var debug, utils, _, Step;
  debug = require('debug')('aw');
  utils = require('./utils');
  _ = require('underscore');
  module.exports = Step = (function(){
    Step.displayName = 'Step';
    var prototype = Step.prototype, constructor = Step;
    function Step(wfId, actor, stepDef){
      this.wfId = wfId;
      this.actor = actor;
      _.extend(this, _.pick(stepDef, 'name'));
      this.id = 's-' + utils.getUuid();
      this.state = 'pending';
      this.canAct = stepDef.canAct;
      this.canEnd = stepDef.canEnd;
      this.actTimes = 0;
    }
    prototype.setNext = function(step){
      return this.next = step;
    };
    prototype.act = function(conditionContext, wfCallback){
      this.wfCallback = wfCallback;
      if (this.canAct.apply(conditionContext)) {
        this._act();
      } else {
        this._callbackWorkflow({
          name: 'step-can-not-act'
        });
      }
    };
    prototype._act = function(){
      var ref$;
      this.actTimes++;
      if ((ref$ = this.state) === 'pending' || ref$ === 'done') {
        this.state = 'acting';
        this._callbackWorkflow({
          name: 'step:start'
        });
      }
      this.__act();
    };
    prototype.__act = function(){
      var this$ = this;
      this.actor.act(this.wfId, this.id, function(ccAfterAct){
        if (this$.canEnd.apply(ccAfterAct)) {
          this$.state = 'done';
          this$._actNext(ccAfterAct);
        } else {
          this$._callbackWorkflow({
            name: 'step-acting'
          });
        }
      });
    };
    prototype._actNext = function(ccAfterAct){
      if (this.next) {
        this._callbackWorkflow({
          name: 'step:end'
        });
        this.next.act(ccAfterAct, this.wfCallback);
      } else {
        this._callbackWorkflow({
          name: 'step:end',
          isFromLastStep: true
        });
      }
    };
    prototype._callbackWorkflow = function(data){
      this.wfCallback(import$({
        stepId: this.id,
        stepName: this.name
      }, data));
    };
    return Step;
  }());
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
