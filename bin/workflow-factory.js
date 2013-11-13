(function(){
  var debug, Workflow, Step, ActorFactory, utils, _, createSteps, createUnwiredSteps, wireSteps, _getNextSteps, getActor;
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
    var i$, ref$, len$, stepDef, step, nextSteps, ref1$, results$ = [];
    for (i$ = 0, len$ = (ref$ = wfDef.steps).length; i$ < len$; ++i$) {
      stepDef = ref$[i$];
      step = steps[stepDef.name];
      if (typeof stepDef.next === 'string') {
        nextSteps = (ref1$ = [], ref1$[0] = {
          step: steps[stepDef.next]
        }, ref1$);
      } else if (_.isArray(stepDef.next)) {
        nextSteps = _getNextSteps(steps, stepDef.next);
      }
      results$.push(step.next = nextSteps);
    }
    return results$;
  };
  _getNextSteps = function(steps, nextDef){
    var createStep, i$, len$, s, results$ = [];
    createStep = function(s){
      if (typeof s === "string") {
        return {
          step: steps[s]
        };
      } else {
        return {
          step: steps[s.name],
          canEnter: s.canEnter
        };
      }
    };
    for (i$ = 0, len$ = nextDef.length; i$ < len$; ++i$) {
      s = nextDef[i$];
      results$.push(createStep(s));
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
        step.workflow = workflow;
      }
      return workflow;
    }
  };
}).call(this);
