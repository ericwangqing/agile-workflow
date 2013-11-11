(function(){
  var debug, workflowFactory, eventBus, _, workflowStore, debugEvent, Engine;
  debug = require('debug')('aw');
  workflowFactory = require('./workflow-factory');
  eventBus = require('./event-bus');
  _ = require('underscore');
  workflowStore = {
    retrieveAllRunningWorkflows: function(){
      return [];
    }
  };
  debugEvent = function(e){
    var stepMessage, message;
    stepMessage = e.stepName ? " step: " + e.stepName + "," : "";
    message = e.name + "," + stepMessage + " workflow-state: " + e.state;
    debug(message);
  };
  module.exports = Engine = (function(){
    Engine.displayName = 'Engine';
    var prototype = Engine.prototype, constructor = Engine;
    function Engine(store, config){
      var self;
      this.store = store;
      this._eventHandler = bind$(this, '_eventHandler', prototype);
      this.humanActStep = bind$(this, 'humanActStep', prototype);
      this.humanExecute = bind$(this, 'humanExecute', prototype);
      self = this;
      this.workflows = (this.store || workflowStore).retrieveAllRunningWorkflows();
      this.config = config
        ? config
        : this._loadConfig();
    }
    prototype.start = function(cfg){
      var i$, ref$, len$, workflow;
      for (i$ = 0, len$ = (ref$ = this.workflows).length; i$ < len$; ++i$) {
        workflow = ref$[i$];
        workflow.act();
      }
      this;
    };
    prototype.add = function(workflowDef, resource){
      var workflow;
      workflow = workflowFactory.createWorkflow(workflowDef, resource, this._eventHandler);
      this.workflows.push(workflow);
      return workflow.initial();
    };
    prototype.execute = function(workflowDef, resource, callback){
      var workflow;
      workflow = this.add(workflowDef, resource);
      eventBus.once("workflow:start:" + workflow.id, function(data){
        var error;
        if (callback) {
          callback(error = null, data);
        }
      });
      workflow.act();
    };
    prototype.humanExecute = function(workflowDef, resource, callback){
      var workflow, ref$;
      workflow = this.add(workflowDef, resource);
      workflow.act();
      this.humanActStep({
        wfid: workflow.id,
        sid: workflow.currentStep.id,
        sname: workflow.currentStep.name,
        nextSid: (ref$ = workflow.currentStep.next) != null ? ref$.id : void 8,
        nextSname: (ref$ = workflow.currentStep.next) != null ? ref$.name : void 8
      }, callback);
    };
    prototype.humanActStep = function(arg$, callback){
      var wfid, sid, step, ccAfterAct;
      wfid = arg$.wfid, sid = arg$.sid;
      step = this.getStep(wfid, sid);
      debug("human-act-step at: " + step.name);
      if (step.next) {
        debug("register once on: workflow:waiting-human-on:" + wfid + "/" + step.next.id + " ", step.next.name);
        eventBus.once("workflow:waiting-human-on:" + wfid + "/" + step.next.id, function(data){
          var error;
          if (callback) {
            callback(error = null, data);
          }
        });
      } else {
        debug("register once on: workflow:end:" + wfid + " ");
        eventBus.once("workflow:end:" + wfid, function(data){
          var error;
          if (callback) {
            callback(error = null, data);
          }
        });
      }
      debug("emit: wf://" + wfid + "/" + sid + "/done ", step.name);
      eventBus.emit("wf://" + wfid + "/" + sid + "/done", ccAfterAct = {});
    };
    prototype.getStep = function(wfid, sid){
      var workflow, i$, ref$, len$, step;
      workflow = this.getWorkflowById(wfid);
      for (i$ = 0, len$ = (ref$ = _.values(workflow.steps)).length; i$ < len$; ++i$) {
        step = ref$[i$];
        if (step.id === sid) {
          return step;
        }
      }
    };
    prototype.getAllRunningWorkflow = function(){
      return this.queryWorkflow(function(){
        return true;
      });
    };
    prototype.getWorkflowById = function(wid){
      var workflows;
      workflows = this.queryWorkflow(function(){
        return this.id === wid;
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
    prototype._eventHandler = function(e){
      var ref$;
      if (e.name.indexOf('workflow') >= 0) {
        if (((ref$ = this.config) != null ? ref$.debug.workflow : void 8) === true) {
          debugEvent(e);
        }
        return eventBus.emit(e.name, e);
      } else {
        if (((ref$ = this.config) != null ? ref$.debug.step : void 8) === true) {
          return debugEvent(e);
        }
      }
    };
    return Engine;
  }());
  function bind$(obj, key, target){
    return function(){ return (target || obj)[key].apply(obj, arguments) };
  }
}).call(this);
