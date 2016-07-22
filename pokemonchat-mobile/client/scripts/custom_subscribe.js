customSubscribe = function(){
  var def = $.Deferred();

  if(arguments.length <= 0)
    dep.reject('arguments is not null.');
  else{
    var callback = function(){};
    if(typeof(arguments[arguments.length - 1]) === 'function')
      callback = arguments[arguments.length - 1];

    var argstr = '';
    for(var i=0;i<arguments.length;i++){
      if(i === arguments.length - 1){
        if(typeof(arguments[i]) != 'function'){
          if(argstr.length > 0)
            argstr += ',';
          argstr += 'arguments[' + i + ']';
        }
      }else{
        if(argstr.length > 0)
          argstr += ',';
        argstr += 'arguments[' + i + ']';
      }
    }

    argstr += ',{onError: function(err){def.reject(err);callback(\'err\', err);},onReady: function(){def.resolve();callback(\'ready\');},onStop: function(){def.resolve();callback(\'stop\');}}';
    eval('Meteor.subscribe(' + argstr + ')');
  }

  return def.promise();
}