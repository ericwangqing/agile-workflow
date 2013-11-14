(function(){
  var debug, Db, Server, MongoClient, workflowFactory, storeCollectionName, mongo, WorkflowStore;
  debug = require('debug')('aw');
  Db = require('mongodb').Db;
  Server = require('mongodb').Server;
  MongoClient = require('mongodb').MongoClient;
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
    prototype.retrieveAllRunningWorkflows = function(callback){
      if (!this.collection) {
        return callback([]);
      } else {
        return this.collection.find({}).toArray(function(err, results){
          var i$, len$, marshalledWorkflow;
          for (i$ = 0, len$ = results.length; i$ < len$; ++i$) {
            marshalledWorkflow = results[i$];
            workflowFactory.unmarshalWorkflow(marshalledWorkflow).store = this;
          }
          callback(results);
        });
      }
    };
    prototype.saveWorkflow = function(marshalledWorkflow, done){
      return this.collection.update({
        _id: marshalledWorkflow.id
      }, marshalledWorkflow, {
        upsert: true
      }, function(error, results){
        if (!!done) {
          done(results);
        }
      });
    };
    return WorkflowStore;
  }());
}).call(this);