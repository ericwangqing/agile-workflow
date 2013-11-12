(function(){
  var debug, Step, _, Workflow;
  debug = require('debug')('aw');
  Step = require('./Step');
  _ = require('underscore');
  module.exports = Workflow = (function(superclass){
    var prototype = extend$((import$(Workflow, superclass).displayName = 'Workflow', Workflow), superclass).prototype, constructor = Workflow;
    function Workflow(arg$){
      this.id = arg$.id, this.name = arg$.name, this.steps = arg$.steps, this.activeSteps = arg$.activeSteps, this.context = arg$.context, this.engineCallback = arg$.engineCallback;
      this.state = 'pending';
    }
    prototype.toString = function(){
      var stepsStrs, step;
      stepsStrs = '\n\t' + (function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = _.values(this.steps)).length; i$ < len$; ++i$) {
          step = ref$[i$];
          results$.push('' + step);
        }
        return results$;
      }.call(this)).join('\n\t') + '\n';
      return "Workflow: '" + this.name + "', id: " + this.id + ", Steps: " + stepsStrs;
    };
    return Workflow;
  }(Step));
  function extend$(sub, sup){
    function fun(){} fun.prototype = (sub.superclass = sup).prototype;
    (sub.prototype = new fun).constructor = sub;
    if (typeof sup.extended == 'function') sup.extended(sub);
    return sub;
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
