(function(){
  var debug, workflowFactory, eventBus, _, workflowStore, Engine;
  debug = require('debug')('aw');
  workflowFactory = require('./workflow-factory');
  eventBus = require('./event-bus');
  _ = require('underscore');
  workflowStore = {
    retrieveAllRunningWorkflows: function(){
      return [];
    }
  };
  module.exports = Engine = (function(){
    Engine.displayName = 'Engine';
    var prototype = Engine.prototype, constructor = Engine;
    function Engine(store, config){
      this.store = store;
      this.workflows = (this.store || workflowStore).retrieveAllRunningWorkflows();
    }
    prototype.add = function(workflowDef, resource){
      var workflow;
      workflow = workflowFactory.createWorkflow(workflowDef, resource, this._eventHandler);
      this.workflows.push(workflow);
      return workflow;
    };
    prototype.humanExecute = function(workflowDef, resource){
      var workflow, i$, ref$, len$, activeStep;
      workflow = this.add(workflowDef, resource);
      for (i$ = 0, len$ = (ref$ = workflow.activeSteps).length; i$ < len$; ++i$) {
        activeStep = ref$[i$];
        activeStep.act();
      }
      return workflow;
    };
    prototype.humanActStep = function(wfid, stepName, humanActResult){
      var step, nextAct;
      step = this.getStep(wfid, stepName);
      return nextAct = step.deferAct(humanActResult);
    };
    prototype.getStep = function(wfid, stepName){
      var workflow, i$, ref$, len$, step;
      workflow = this.getWorkflowById(wfid);
      for (i$ = 0, len$ = (ref$ = _.values(workflow.steps)).length; i$ < len$; ++i$) {
        step = ref$[i$];
        if (step.name === stepName) {
          return step;
        }
      }
    };
    prototype.getAllRunningWorkflow = function(){
      return this.queryWorkflow(function(){
        return true;
      });
    };
    prototype.getWorkflowById = function(wfid){
      var workflows;
      workflows = this.queryWorkflow(function(){
        return this.id === wfid;
      });
      return workflows[0];
    };
    prototype.queryWorkflow = function(query){
      var results, i$, ref$, len$, workflow;
      results = [];
      for (i$ = 0, len$ = (ref$ = this.workflows).length; i$ < len$; ++i$) {
        workflow = ref$[i$];
        if (query.apply(workflow, null)) {
          results.push(workflow);
        }
      }
      return results;
    };
    prototype._loadConfig = function(){
      return {};
    };
    return Engine;
  }());
}).call(this);
