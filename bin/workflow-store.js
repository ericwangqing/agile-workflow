(function(){
  var debug, async, Db, Server, MongoClient, Workflow, workflowFactory, storeCollectionName, mongo, WorkflowStore;
  debug = require('debug')('aw');
  async = require('async');
  Db = require('mongodb').Db;
  Server = require('mongodb').Server;
  MongoClient = require('mongodb').MongoClient;
  Workflow = require('./Workflow');
  workflowFactory = require('./workflow-factory');
  storeCollectionName = 'workflow';
  mongo = {
    host: 'localhost',
    port: 3002,
    db: 'agile-workflow',
    writeConcern: -1
  };
  module.exports = WorkflowStore = (function(){
    WorkflowStore.displayName = 'WorkflowStore';
    var prototype = WorkflowStore.prototype, constructor = WorkflowStore;
    WorkflowStore.con = null;
    function WorkflowStore(db, done){
      var this$ = this;
      if (this.isMongoConnection(db)) {
        constructor.con = db;
        this.collection = constructor.con.collection(storeCollectionName);
        done(this);
      } else {
        constructor.con = new Db(mongo.db, new Server(mongo.host, mongo.port), {
          w: mongo.writeConcern
        });
        constructor.con.open(function(err, con){
          if (err) {
            console.log("database connection error: ", err);
          } else {
            this$.collection = constructor.con.collection(storeCollectionName);
            done(this$);
          }
        });
      }
    }
    prototype.isMongoConnection = function(db){
      return !!db;
    };
    prototype.retrieveAllWorkflows = function(callback){
      if (!this.collection) {
        return callback([]);
      } else {
        return this.collection.find({}).toArray(function(err, results){
          var workflows, i$, len$, marshalledWorkflow, workflow;
          workflows = [];
          if (results.length === 2) {
            debug("KKKKKKKKKKK ", results[0].steps);
            debug("KKKKKKKKKKK ", results[1].steps);
          }
          for (i$ = 0, len$ = results.length; i$ < len$; ++i$) {
            marshalledWorkflow = results[i$];
            Workflow.unmarshal(marshalledWorkflow);
            workflow = workflowFactory.resumeMarshalledWorkflow(marshalledWorkflow);
            workflows.push(workflow);
          }
          callback(workflows);
        });
      }
    };
    prototype.saveAllWorkflows = function(workflows, done){
      var this$ = this;
      return async.each(workflows, function(workflow, callback){
        return this$.saveWorkflow(workflow, callback);
      }, done);
    };
    prototype.saveWorkflow = function(workflow, done){
      var marshalledWorkflow;
      marshalledWorkflow = Workflow.marshal(workflow);
      debug("marshalled-workflow: ", marshalledWorkflow);
      return this.collection.update({
        _id: marshalledWorkflow._id
      }, marshalledWorkflow, {
        upsert: true
      }, function(error, results){
        debug("****************** saved");
        if (!!done) {
          done();
        }
      });
    };
    return WorkflowStore;
  }());
}).call(this);
