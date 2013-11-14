(function(){
  var debug, Workflow, Step, ActorFactory, utils, _, createSteps, createUnwiredSteps, restoreState, wireSteps, _getNextSteps, getActor;
  debug = require('debug')('aw');
  Workflow = require('./Workflow');
  Step = require('./Step');
  ActorFactory = require('./Actor-factory');
  utils = require('./utils');
  _ = require('underscore');
  createSteps = function(wfDef, context, marshalledWorkflow){
    var steps;
    steps = createUnwiredSteps(wfDef, context, marshalledWorkflow);
    wireSteps(steps, wfDef);
    return steps;
  };
  createUnwiredSteps = function(wfDef, context, marshalledWorkflow){
    var steps, i$, ref$, len$, stepDef, actor, step;
    steps = {};
    for (i$ = 0, len$ = (ref$ = wfDef.steps).length; i$ < len$; ++i$) {
      stepDef = ref$[i$];
      actor = getActor(stepDef.actor);
      step = new Step({
        actor: actor,
        context: context,
        stepDef: stepDef
      });
      if (marshalledWorkflow) {
        restoreState(step, marshalledWorkflow);
      }
      steps[stepDef.name] = step;
    }
    return steps;
  };
  restoreState = function(step, marshalledWorkflow){
    var i$, ref$, len$, marshalledStep;
    for (i$ = 0, len$ = (ref$ = marshalledWorkflow.steps).length; i$ < len$; ++i$) {
      marshalledStep = ref$[i$];
      if (step.name === marshalledStep.name) {
        step.state = marshalledStep.state;
        step.actTimes = marshalledStep.actTimes;
      }
    }
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
  getActor = function(type){
    return ActorFactory.createActor(type || 'human');
  };
  module.exports = {
    createWorkflow: function(wfDef, marshalledWorkflow){
      var context, steps, id, workflow, i$, ref$, len$, step;
      context = _.extend({}, (marshalledWorkflow != null ? marshalledWorkflow.context : void 8) || wfDef.context);
      steps = createSteps(wfDef, context, marshalledWorkflow);
      id = 'wf-' + utils.getUuid();
      workflow = new Workflow({
        id: id,
        steps: steps,
        context: context,
        wfDef: wfDef
      });
      for (i$ = 0, len$ = (ref$ = _.values(steps)).length; i$ < len$; ++i$) {
        step = ref$[i$];
        step.workflow = workflow;
      }
      return workflow;
    }
  };
}).call(this);
