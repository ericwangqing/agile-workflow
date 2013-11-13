(function(){
  var debug, Workflow, Step, ActorFactory, utils, _, createSteps, createUnwiredSteps, wireSteps, getActor;
  debug = require('debug')('aw');
  Workflow = require('./Workflow');
  Step = require('./Step');
  ActorFactory = require('./Actor-factory');
  utils = require('./utils');
  _ = require('underscore');
  createSteps = function(wfDef, context, resource){
    var steps;
    steps = createUnwiredSteps(wfDef, context, resource);
    wireSteps(steps, wfDef);
    return steps;
  };
  createUnwiredSteps = function(wfDef, context, resource){
    var steps, i$, ref$, len$, stepDef, actor;
    steps = {};
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
    var i$, ref$, len$, stepDef, step, results$ = [];
    for (i$ = 0, len$ = (ref$ = wfDef.steps).length; i$ < len$; ++i$) {
      stepDef = ref$[i$];
      step = steps[stepDef.name];
      results$.push(step.setNext(steps[stepDef.next]));
    }
    return results$;
  };
  getActor = function(type, resource){
    return ActorFactory.createActor(type || 'human');
  };
  module.exports = {
    createWorkflow: function(wfDef, resource, engineCallback){
      var context, steps, id, workflow, ref$, i$, len$, step;
      context = _.extend({}, wfDef.context);
      steps = createSteps(wfDef, context, resource);
      id = 'wf-' + utils.getUuid();
      workflow = new Workflow((ref$ = {
        id: id,
        steps: steps,
        context: context,
        engineCallback: engineCallback
      }, ref$.name = wfDef.name, ref$.canAct = wfDef.canAct, ref$.canEnd = wfDef.canEnd, ref$));
      for (i$ = 0, len$ = (ref$ = _.values(steps)).length; i$ < len$; ++i$) {
        step = ref$[i$];
        step.setWorkflow(workflow);
      }
      return workflow;
    }
  };
}).call(this);
