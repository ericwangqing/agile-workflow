(function(){
  var debug, Workflow, Step, ActorFactory, utils, createSteps, createUnwiredSteps, wireSteps, getActor;
  debug = require('debug')('aw');
  Workflow = require('./Workflow');
  Step = require('./Step');
  ActorFactory = require('./Actor-factory');
  utils = require('./utils');
  createSteps = function(wid, wfDef, resource){
    var steps, startStep;
    steps = createUnwiredSteps(wid, wfDef, resource);
    startStep = wireSteps(steps, wfDef);
    return [steps, startStep];
  };
  createUnwiredSteps = function(wid, wfDef, resource){
    var steps, i$, ref$, len$, stepDef, actor;
    steps = {};
    for (i$ = 0, len$ = (ref$ = wfDef.steps).length; i$ < len$; ++i$) {
      stepDef = ref$[i$];
      actor = getActor(stepDef.actor, resource);
      steps[stepDef.name] = new Step(wid, actor, stepDef);
    }
    return steps;
  };
  wireSteps = function(steps, wfDef){
    var i$, ref$, len$, stepDef, step, startStep;
    for (i$ = 0, len$ = (ref$ = wfDef.steps).length; i$ < len$; ++i$) {
      stepDef = ref$[i$];
      step = steps[stepDef.name];
      step.setNext(steps[stepDef.next]);
      if (stepDef.isStart) {
        startStep = step;
      }
    }
    return startStep;
  };
  getActor = function(type, resource){
    return ActorFactory.createActor(type || 'human');
  };
  module.exports = {
    createWorkflow: function(wfDef, resource, engineCallback){
      var wid, ref$, steps, startStep, startConditionContext;
      wid = 'wf-' + utils.getUuid();
      ref$ = createSteps(wid, wfDef, resource), steps = ref$[0], startStep = ref$[1];
      startConditionContext = null;
      return new Workflow(wid, wfDef.name, steps, startStep, startConditionContext, engineCallback);
    }
  };
}).call(this);
