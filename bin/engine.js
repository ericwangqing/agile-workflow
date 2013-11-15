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
      return this.store.retrieveAllWorkflows(function(workflows){
        this$.workflows = workflows;
        done();
      });
    };
    prototype.stop = function(done){
      var this$ = this;
      return this.store.saveAllWorkflows(this.workflows, function(){
        WorkflowStore.con.dropDatabase(done);
      });
    };
    prototype.add = function(workflowDef, done){
      var workflow;
      workflow = workflowFactory.createWorkflow(workflowDef);
      workflow.store = this.store;
      this.workflows.push(workflow);
      workflow.save(function(){});
      return done(workflow);
    };
    prototype.humanStart = function(workflowDef, done){
      return this.add(workflowDef, function(workflow){
        var i$, ref$, len$, activeStep;
        for (i$ = 0, len$ = (ref$ = workflow.activeSteps()).length; i$ < len$; ++i$) {
          activeStep = ref$[i$];
          activeStep.act();
        }
        done(workflow);
      });
    };
    prototype.humanActStep = function(wfid, stepName, humanActResult){
      var workflow;
      workflow = this.getWorkflowById(wfid);
      return workflow.humanDo(stepName, humanActResult);
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
