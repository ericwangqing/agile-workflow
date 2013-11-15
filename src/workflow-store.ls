require! ['async', 'mongodb'.Db, 'mongodb'.Server, 'mongodb'.MongoClient, './Workflow', './workflow-factory']

store-collection-name = 'workflow'
mongo =
  host: \localhost
  port: 3002 # Meteor mongoDB
  db: \agile-workflow
  write-concern: -1 # 'majority' , MongoDB在write concern上又变化，这里需要进一步查清如何应对。-1就是以前的safe。


module.exports = class Workflow-store
  @con = null
  (db, done)-> # 目前只支持mongoDB
    if @is-mongo-connection db
      @@con = db
      @collection = @@con.collection store-collection-name
      done @
    else
      # create connection
      @@con = new Db mongo.db, (new Server mongo.host, mongo.port), w: mongo.write-concern
      (err, con) <~! @@con.open
      if err
        console.log "database connection error: ", err
      else
        @collection = @@con.collection store-collection-name
        done @

  is-mongo-connection: (db)->
    !!db

  retrieve-all-workflows: (callback)-> 
    if not @collection
      callback [] 
    else
      # _workflow-store.retrieve-all-workflows!
      (err, results) <-! @collection.find {} .to-array
      # debug "error: #err"
      workflows = []
      # debug "KKKKKKKKKKK #{results.length}"
      for marshalled-workflow in results
        Workflow.unmarshal marshalled-workflow
        workflow = workflow-factory.resume-marshalled-workflow marshalled-workflow
        # debug "^^^^^^^^^", workflow
        workflows.push workflow
      callback workflows

  save-all-workflows: (workflows, done)->
    async.each workflows, (workflow, callback)~>
      @save-workflow workflow, callback
    , done

  save-workflow: (workflow, done)->
    # console.log "before workflow save"
    marshalled-workflow = Workflow.marshal workflow
    # debug "marshalled-workflow: ", marshalled-workflow 
    (error, results) <-! @collection.update {_id: marshalled-workflow.id}, marshalled-workflow, {upsert: true}
    done results if !!done
    # debug "save workflow after:  ", workflow
