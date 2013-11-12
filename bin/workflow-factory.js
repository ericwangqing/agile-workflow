(function(){
  var debug, Workflow, Step, ActorFactory, utils, _, createSteps, createUnwiredSteps, wireSteps, getActor;
  debug = require('debug')('aw');
  Workflow = require('./Workflow');
  Step = require('./Step');
  ActorFactory = require('./Actor-factory');
  utils = require('./utils');
  _ = require('underscore');
  createSteps = function(wfDef, resource){
    var steps, activeSteps;
    steps = createUnwiredSteps(wfDef, resource);
    activeSteps = wireSteps(steps, wfDef);
    return {
      steps: steps,
      activeSteps: activeSteps
    };
  };
  createUnwiredSteps = function(wfDef, resource){
    var steps, context, i$, ref$, len$, stepDef, actor;
    steps = {};
    context = utils.deepCopy(wfDef.context);
    for (i$ = 0, len$ = (ref$ = wfDef.steps).length; i$ < len$; ++i$) {
      stepDef = ref$[i$];
      actor = getActor(stepDef.actor, resource);
      steps[stepDef.name] = new Step({
        actor: actor,
        context: context,
        stepDef: stepDef
      });
    }
    return steps;
  };
  wireSteps = function(steps, wfDef){
    var activeSteps, i$, ref$, len$, stepDef, step;
    activeSteps = [];
    for (i$ = 0, len$ = (ref$ = wfDef.steps).length; i$ < len$; ++i$) {
      stepDef = ref$[i$];
      step = steps[stepDef.name];
      step.setNext(steps[stepDef.next]);
      if (stepDef.isStartActive) {
        activeSteps.push(step);
      }
    }
    return activeSteps;
  };
  getActor = function(type, resource){
    return ActorFactory.createActor(type || 'human');
  };
  module.exports = {
    createWorkflow: function(wfDef, resource, engineCallback){
      var ref$, steps, activeSteps, context, id, workflow, i$, len$, step;
      ref$ = createSteps(wfDef, resource), steps = ref$.steps, activeSteps = ref$.activeSteps;
      context = null;
      id = 'wf-' + utils.getUuid();
      workflow = new Workflow({
        id: id,
        name: wfDef.name,
        steps: steps,
        activeSteps: activeSteps,
        context: context,
        engineCallback: engineCallback
      });
      for (i$ = 0, len$ = (ref$ = _.values(steps)).length; i$ < len$; ++i$) {
        step = ref$[i$];
        step.setWorkflow(workflow);
      }
      return workflow;
    }
  };
}).call(this);
