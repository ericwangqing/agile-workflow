(function(){
  var debug, workflowFactory, eventBus, WorkflowStore, _, Engine;
  debug = require('debug')('aw');
  workflowFactory = require('./workflow-factory');
  eventBus = require('./event-bus');
  WorkflowStore = require('./Workflow-store');
  _ = require('underscore');
  module.exports = Engine = (function(){
    Engine.displayName = 'Engine';
    var prototype = Engine.prototype, constructor = Engine;
    function Engine(db, done){
      var this$ = this;
      new WorkflowStore(db, function(store){
        this$.store = store;
        return done(this$);
      });
    }
    prototype.start = function(done){
      var this$ = this;
      debug("LLLLLLLLLLLLLL");
      return this.store.retrieveAllRunningWorkflows(function(workflows){
        this$.workflows = workflows;
        done();
      });
    };
    prototype.add = function(workflowDef){
      var workflow;
      workflow = workflowFactory.createWorkflow(workflowDef);
      workflow.store = this.store;
      this.workflows.push(workflow);
      workflow.save();
      return workflow;
    };
    prototype.humanStart = function(workflowDef){
      var workflow, i$, ref$, len$, activeStep;
      workflow = this.add(workflowDef);
      for (i$ = 0, len$ = (ref$ = workflow.activeSteps()).length; i$ < len$; ++i$) {
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
