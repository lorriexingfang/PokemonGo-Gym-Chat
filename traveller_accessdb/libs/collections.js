// wifi 认为离线的时长（10分钟）
WIFI_TIMEOUT = 10*60*1000;

// 系统帐号
TRAVELLER_HELPER = 'system-helper';   // 搭伙小助手
TRAVELLER_BELL = 'system-bell';       // 搭伙小喇叭
TRAVELLER_MESSAGE = 'system-message'; // 搭伙消息
TRAVELLER_NEWS = 'system-news';       // 本地资讯

//client
mongoPosts = new Mongo.Collection('posts');
Posts = mongoPosts;//new Ground.Collection(mongoPosts);
mongoTags = new Mongo.Collection('tags');
Tags  = mongoTags;//new Ground.Collection(mongoTags); //塔伙标签
var mongoPartner = new Mongo.Collection('partner');
Partner= mongoPartner;//new Ground.Collection(mongoPartner); //塔伙
mongoPushToken = new Mongo.Collection('pushToken');
PushToken = mongoPushToken;//new Ground.Collection(mongoPushToken);
var mongoSms = new Mongo.Collection('sms');
Sms  = mongoSms;//new Ground.Collection(mongoSms);  //短信发送成功
var mongoShops = new Mongo.Collection('shops');
Shops = mongoShops;//new Ground.Collection(mongoShops);//商户、旅社
mongoChats = new Mongo.Collection("chats");
Chats = mongoChats;//new Ground.Collection(mongoChats);//聊天信息
mongoChatUsers = new Meteor.Collection("chatUsers");
ChatUsers = mongoChatUsers;//new Ground.Collection(mongoChatUsers);//聊天的最近聊系人
var mongoPhotos = new Mongo.Collection("photos");
Photos = mongoPhotos;//new Ground.Collection(mongoPhotos);//用户相册
var mongoEvents = new Mongo.Collection("events");
Events = mongoEvents;
mongoChatUsers.allow({
   update:function(){
       return true;
   }

})