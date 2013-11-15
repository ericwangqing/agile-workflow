(function(){
  var debug, Workflow, Step, ActorFactory, utils, _, createSteps, createUnwiredSteps, restoreStepsState, restoreStepState, wireSteps, _getNextSteps, getActor, _createWorkflow;
  debug = require('debug')('aw');
  Workflow = require('./Workflow');
  Step = require('./Step');
  ActorFactory = require('./Actor-factory');
  utils = require('./utils');
  _ = require('underscore');
  createSteps = function(wfDef, context){
    var steps;
    steps = createUnwiredSteps(wfDef, context);
    wireSteps(steps, wfDef);
    return steps;
  };
  createUnwiredSteps = function(wfDef, context){
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
      steps[stepDef.name] = step;
    }
    return steps;
  };
  restoreStepsState = function(workflow, marshalledSteps){
    var i$, ref$, len$, step;
    for (i$ = 0, len$ = (ref$ = _.values(workflow.steps)).length; i$ < len$; ++i$) {
      step = ref$[i$];
      restoreStepState(step, marshalledSteps);
    }
  };
  restoreStepState = function(step, marshalledSteps){
    var i$, len$, marshalledStep;
    for (i$ = 0, len$ = marshalledSteps.length; i$ < len$; ++i$) {
      marshalledStep = marshalledSteps[i$];
      if (marshalledStep.name === step.name) {
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
  _createWorkflow = function(wfDef, marshalledWorkflowId){
    var context, steps, id, workflow, i$, ref$, len$, step;
    context = _.extend({}, wfDef.context);
    steps = createSteps(wfDef, context);
    id = marshalledWorkflowId || 'wf-' + utils.getUuid();
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
  };
  module.exports = {
    createWorkflow: function(wfDef){
      return _createWorkflow(wfDef);
    },
    resumeMarshalledWorkflow: function(marshalledWorkflow){
      var workflow;
      workflow = _createWorkflow(marshalledWorkflow.wfDef, marshalledWorkflow._id);
      restoreStepsState(workflow, marshalledWorkflow.steps);
      return workflow;
    }
  };
}).call(this);
