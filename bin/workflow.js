(function(){
  var debug, Step, guard, _, Workflow;
  debug = require('debug')('aw');
  Step = require('./Step');
  guard = require('./guard');
  _ = require('underscore');
  module.exports = Workflow = (function(superclass){
    var prototype = extend$((import$(Workflow, superclass).displayName = 'Workflow', Workflow), superclass).prototype, constructor = Workflow;
    Workflow.marshal = function(workflow){
      var marshalledWorkflow, res$, i$, ref$, len$, step;
      marshalledWorkflow = _.pick(workflow, 'name', 'state', 'context', 'wfDef');
      marshalledWorkflow._id = workflow.id;
      guard.stringifyWorkflowDefGuards(marshalledWorkflow.wfDef);
      res$ = [];
      for (i$ = 0, len$ = (ref$ = _.values(workflow.steps)).length; i$ < len$; ++i$) {
        step = ref$[i$];
        res$.push(step.marshal());
      }
      marshalledWorkflow.steps = res$;
      return marshalledWorkflow;
    };
    Workflow.unmarshal = function(marshalledWorkflow){
      return guard.restoreWorkflowDefGuards(marshalledWorkflow.wfDef);
    };
    function Workflow(arg$){
      this.id = arg$.id, this.steps = arg$.steps, this.context = arg$.context, this.wfDef = arg$.wfDef;
      this.state = 'pending';
      this.name = this.wfDef.name;
      this.canAct = this.wfDef.canAct || function(){
        return true;
      };
      this.canEnd = this.wfDef.canEnd || function(){
        return true;
      };
    }
    prototype.humanDo = function(stepName, humanActResult){
      return this.steps[stepName].deferAct(humanActResult);
    };
    prototype.retryContextAwareSteps = function(){
      var i$, ref$, len$, step, ref1$, results$ = [];
      for (i$ = 0, len$ = (ref$ = this.contextAwareSteps()).length; i$ < len$; ++i$) {
        step = ref$[i$];
        if (((ref1$ = step.state) !== 'end' && ref1$ !== 'acting') && step.canAct.apply(step.context)) {
          step.state = 'active';
          results$.push(step.act());
        }
      }
      return results$;
    };
    prototype.contextAwareSteps = function(){
      var i$, ref$, len$, step, results$ = [];
      for (i$ = 0, len$ = (ref$ = _.values(this.steps)).length; i$ < len$; ++i$) {
        step = ref$[i$];
        if (step.isContextAware) {
          results$.push(step);
        }
      }
      return results$;
    };
    prototype.actingSteps = function(){
      var i$, ref$, len$, step, results$ = [];
      for (i$ = 0, len$ = (ref$ = _.values(this.steps)).length; i$ < len$; ++i$) {
        step = ref$[i$];
        if (step.state === 'acting') {
          results$.push(step);
        }
      }
      return results$;
    };
    prototype.activeSteps = function(){
      var i$, ref$, len$, step, results$ = [];
      for (i$ = 0, len$ = (ref$ = _.values(this.steps)).length; i$ < len$; ++i$) {
        step = ref$[i$];
        if (step.state === 'active') {
          results$.push(step);
        }
      }
      return results$;
    };
    prototype.activeAndActingSteps = function(){
      var i$, ref$, len$, step, ref1$, results$ = [];
      for (i$ = 0, len$ = (ref$ = _.values(this.steps)).length; i$ < len$; ++i$) {
        step = ref$[i$];
        if ((ref1$ = step.state) === 'active' || ref1$ === 'acting') {
          results$.push(step);
        }
      }
      return results$;
    };
    prototype.isGoingToEnd = function(step){
      return !!step.isEndStep || (!step.next && this.canEnd());
    };
    prototype.save = function(done){
      var this$ = this;
      return this.store.saveWorkflow(this, function(){
        debug("save workflow: " + this$.id + " complete!");
        done();
      });
    };
    prototype.toString = function(){
      var stepsStrs, step;
      stepsStrs = '\n\t' + (function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = _.values(this.steps)).length; i$ < len$; ++i$) {
          step = ref$[i$];
          results$.push('' + step);
        }
        return results$;
      }.call(this)).join('\n\t') + '\n';
      return "Workflow: '" + this.name + "', id: " + this.id + ", Steps: " + stepsStrs;
    };
    prototype.showStepInState = function(state){
      var steps;
      steps = this[state + 'Steps']();
      debug(state + "-steps: " + steps);
    };
    return Workflow;
  }(Step));
  function extend$(sub, sup){
    function fun(){} fun.prototype = (sub.superclass = sup).prototype;
    (sub.prototype = new fun).constructor = sub;
    if (typeof sup.extended == 'function') sup.extended(sub);
    return sub;
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
