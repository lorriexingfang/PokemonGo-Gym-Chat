//正在搭伙
getLatestFindPartner = function(){
  return mongoPosts.find({type: 'pub_board'}, {sort: {createdAt: -1},limit:3});
}
getPostsLists = function(){
  return Posts.find({type: 'pub_board'}, {sort: {toJoin: -1,createdAt: -1},limit:50});
}
getPostsNew = function(){
  return Posts.find({type:'pub_board'}, {sort: {createdAt: -1},limit:50});
}
//显示搭伙时的游记
getNotesFirst = function(tag){
  return Posts.findOne({type: 'notes', tags: {$in: [tag]}},{sort:{createdAt:-1}})
}
//评论信息
getPostReply = function(id){
  var post = Posts.findOne({_id: id});
  if(post === undefined || post.replys === undefined)
    return []
  else
    return Posts.findOne({_id: id}).replys.sort(function(a, b){
      if(a.createdAt > b.createdAt)
        return -1;
      else if(a.createdAt < b.createdAt)
        return 1;
      else
        return 0;
  });
}
//搜索
searchingPost = function(key){
  var k = new RegExp(key);
  return Posts.find({'type':'pub_board','$or':[{'title':k},{'text':k}]}, {sort: {createdAt: -1},limit:50});
}

// 获取用户昵称
// @userId:
// @business: 是否商家，为true，则会优先返回商家名称
getUserName = function(userId, business){
  var user = Meteor.users.findOne(userId);
  if (user == undefined || user == null)
    return '';
  if(business && user.profile.isBusiness)
    return user.profile.business;
  if(user.profile.nike === undefined || user.profile.nike === '')
    return user.username.split('#')[0];
  
  return user.profile.nike;
}