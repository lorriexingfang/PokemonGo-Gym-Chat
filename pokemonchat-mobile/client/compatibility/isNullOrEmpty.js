// 对象是否有为 null/undefined/'' 的値
function isNullOrEmpty(){
  if(arguments.length <= 0)
    throw new Error('参数不为能空！');
  else{
    for(var i=0;i< arguments.length-1;i++){
      if(arguments[i] === null || arguments[i] === undefined || arguments[i] === '')
        return true;
    }
    return false;
  }
}

// 对象是否全部为 null/undefined/'' 的值
function isNullOrEmptyByAll(){
  if(arguments.length <= 0)
    throw new Error('参数不为能空！');
  else{
    var result = true;
    for(var i=0;i< arguments.length-1;i++){
      if(arguments[i] != null && arguments[i] != undefined && arguments[i] != ''){
        result = false;
        break;
      }
    }
    return result;
  }
}