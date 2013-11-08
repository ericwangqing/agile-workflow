(function(){
  var debug, workflowFactory, eventBus, workflowStore, debugEvent;
  debug = require('debug')('aw');
  workflowFactory = require('./workflow-factory');
  eventBus = require('./event-bus');
  workflowStore = {
    retrieveAllRunningWorkflows: function(){
      return [];
    }
  };
  debugEvent = function(e){
    var stepMessage, message;
    stepMessage = e.stepName ? " step: " + e.stepName + "," : "";
    message = e.name + "," + stepMessage + " workflow-state: " + e.wfCurrentState;
    debug(message);
  };
  module.exports = {
    workflows: [],
    add: function(workflowDef, resource){
      this.workflows.push(workflowFactory.createWorkflow(workflowDef, resource, this._eventHandler));
      return this;
    },
    start: function(){
      var i$, ref$, len$, workflow;
      this.workflows.concat(workflowStore.retrieveAllRunningWorkflows());
      for (i$ = 0, len$ = (ref$ = this.workflows).length; i$ < len$; ++i$) {
        workflow = ref$[i$];
        workflow.act();
      }
      this;
    },
    getAllRunningWorkflow: function(){
      return this.queryWorkflow(function(){
        return true;
      });
    },
    queryWorkflow: function(query){
      var results, i$, ref$, len$, workflow;
      results = [];
      for (i$ = 0, len$ = (ref$ = this.workflows).length; i$ < len$; ++i$) {
        workflow = ref$[i$];
        if (query.apply(workflow, null)) {
          results.push(workflow);
        }
      }
      return results;
    },
    _eventHandler: function(e){
      if (e.name.indexOf('workflow') >= 0) {
        return eventBus.emit(e.name, e);
      } else {
        return debugEvent(e);
      }
    }
  };
}).call(this);
