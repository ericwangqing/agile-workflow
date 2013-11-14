(function(){
  var debug, Step, _, Workflow;
  debug = require('debug')('aw');
  Step = require('./Step');
  _ = require('underscore');
  module.exports = Workflow = (function(superclass){
    var prototype = extend$((import$(Workflow, superclass).displayName = 'Workflow', Workflow), superclass).prototype, constructor = Workflow;
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
      console.log("before workflow save");
      return this.store.saveWorkflow(this.marshal(), done);
    };
    prototype.marshal = function(){
      var marshalWorkflow, res$, i$, ref$, len$, step;
      marshalWorkflow = _.pick(this, 'name', 'id', 'state', 'wfDef', 'context');
      res$ = [];
      for (i$ = 0, len$ = (ref$ = this.steps).length; i$ < len$; ++i$) {
        step = ref$[i$];
        res$.push(step.marshal());
      }
      marshalWorkflow.steps = res$;
      return marshalWorkflow;
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
