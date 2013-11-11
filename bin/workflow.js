(function(){
  var debug, Step, Workflow;
  debug = require('debug')('aw');
  Step = require('./Step');
  module.exports = Workflow = (function(superclass){
    var prototype = extend$((import$(Workflow, superclass).displayName = 'Workflow', Workflow), superclass).prototype, constructor = Workflow;
    function Workflow(id, name, steps, startStep, startConditionContext, engineCallback){
      this.id = id;
      this.name = name;
      this.steps = steps;
      this.startStep = startStep;
      this.startConditionContext = startConditionContext;
      this.engineCallback = engineCallback;
      this.stepEventHandler = bind$(this, 'stepEventHandler', prototype);
      this.state = 'pending';
      this.currentStep = null;
      this._callbackEngine({
        name: "workflow:created:" + this.id
      });
    }
    prototype.initial = function(){
      return this;
    };
    prototype.act = function(){
      if (this.currentStep === null) {
        this.currentStep = this.startStep;
      }
      this.currentStep.act(this.startConditionContext, this.stepEventHandler);
      return this;
    };
    prototype.getStepIdByName = function(name){
      return this.steps[name].id;
    };
    prototype.stepEventHandler = function(event){
      this._callbackEngine(event);
      this.translateToAndHandleWorkflowEvent(event);
    };
    prototype.translateToAndHandleWorkflowEvent = function(event){
      if (event.name === 'step:start' && this.state === 'pending') {
        this.state = 'start';
        this._callbackEngine({
          name: "workflow:start:" + this.id,
          nextAct: this.currentStep
        });
      }
      if (event.name === 'step:acting') {
        this._callbackEngine({
          name: "workflow:acted-on:" + this.id + "/" + this.currentStep.id,
          nextAct: this.currentStep
        });
      }
      if (event.name === 'step:end') {
        this._callbackEngine({
          name: "workflow:acted-on:" + this.id + "/" + this.currentStep.id,
          nextAct: this.currentStep.next
        });
        if (event.isFromLastStep) {
          this.state = 'end';
          this._callbackEngine({
            name: "workflow:end:" + this.id
          });
        } else {
          this.currentStep = this.currentStep.next;
          this.currentStep.act(event.conditionContext, this.stepEventHandler);
          this._callbackEngine({
            name: "workflow:waiting-human-on:" + this.id + "/" + this.currentStep.id,
            nextAct: this.currentStep
          });
        }
      }
    };
    prototype._callbackEngine = function(data){
      this.engineCallback(import$({
        wfid: this.id,
        state: this.state
      }, data));
    };
    return Workflow;
  }(Step));
  function bind$(obj, key, target){
    return function(){ return (target || obj)[key].apply(obj, arguments) };
  }
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
