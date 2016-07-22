// wifi 认为离线的时长（10分钟）
WIFI_TIMEOUT = 10*60*1000;

// 系统帐号
TRAVELLER_HELPER = 'system-helper';   // 搭伙小助手
TRAVELLER_BELL = 'system-bell';       // 搭伙小喇叭
TRAVELLER_MESSAGE = 'system-message'; // 搭伙消息
TRAVELLER_NEWS = 'system-news';       // 本地资讯
TRAVELLER_SYSTEM = 'system-msg';      // 系统消息
TRAVELLER_SECURECLONEBOX = 'system-secureclonebox'; //克隆大密盒

////server
//mongoPosts = new Mongo.Collection('posts');
//Posts = new Ground.Collection(mongoPosts);
//var mongoTags = new Mongo.Collection('tags');
//Tags  = new Ground.Collection(mongoTags); //塔伙标签
//var mongoPartner = new Mongo.Collection('partner');
//Partner= new Ground.Collection(mongoPartner); //塔伙
//mongoPushToken = new Mongo.Collection('pushToken');
//PushToken = new Ground.Collection(mongoPushToken);
//var mongoSms = new Mongo.Collection('sms');
//Sms  = new Ground.Collection(mongoSms);  //短信发送成功
//var mongoShops = new Mongo.Collection('shops');
//Shops = new Ground.Collection(mongoShops);//商户、旅社
//mongoChats = new Mongo.Collection("chats");
//Chats = new Ground.Collection(mongoChats);//聊天信息
//mongoChatUsers = new Mongo.Collection("chatUsers");
//ChatUsers = new Ground.Collection(mongoChatUsers);//聊天的最近聊系人
//var mongoPhotos = new Mongo.Collection("photos");
//Photos = new Ground.Collection(mongoPhotos);//用户相册

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
Scores = new Mongo.Collection("scores")

NearbyWifiLists = new Mongo.Collection(null);

if(Meteor.isServer){
  root.RefNames = new Meteor.Collection("refnames");

  // 生成测试数据
  if(RefNames.find({}).count() <= 0){
    RefNames.insert({text: '李白'});
    RefNames.insert({text: '赵云'});
    RefNames.insert({text: '大白'});
    RefNames.insert({text: '曹操'});
    RefNames.insert({text: '林冲'});
  }
}


mongoChatUsers.allow({
   update:function(){
       return true;
   }

});
mongoChats.allow({
    remove:function(){
       return true;
   }
});

var mongoWifis = new Mongo.Collection("wifis");
Wifis = mongoWifis;

var mongoWifiUsers = new Mongo.Collection("wifiUsers");
WifiUsers = mongoWifiUsers;

var mongoWifiPosts = new Mongo.Collection("wifiPosts");
WifiPosts = mongoWifiPosts;

var mongoWifiHistory = new Mongo.Collection("wifiHistory");
WifiHistory = mongoWifiHistory;

var mongoSuperWifis = new Mongo.Collection("superWifis");
SuperWifis = mongoSuperWifis;

var mongoWifiFavorite = new Mongo.Collection("wifiFavorite");
WifiFavorite = mongoWifiFavorite;

var mongoWifiPhotos = new Mongo.Collection('wifiPhotos')
WifiPhotos = mongoWifiPhotos;

if(Meteor.isServer){
    SearchSource.defineSource('wifiBusiness', function(searchText, options) {
        var options2 = {fields: {'profile':1, 'business': 1}, sort: {'business.readCount': -1}, limit: 20};
        if (options && options.limit) {
            options2.limit = options.limit;
        }

        if(searchText) {
             var regExp = buildRegExp(searchText);
             var selector = {$or: [
        	        {'profile.business': regExp},
                	{'profile.address': regExp},
                    {'profile.tel': regExp}
                    ]};
             return Meteor.users.find(selector, options2).fetch();
        } else {
             return Meteor.users.find({}, options2).fetch();
        }
    });

    function buildRegExp(searchText) {
        // this is a dumb implementation
        var parts = searchText.trim().split(/[ \-\:]+/);
        return new RegExp("(" + parts.join('|') + ")", "ig");
    }
}

if(Meteor.isClient){
    var options = {
        keepHistory: 0, //1000 * 60 * 5,
        localSearch: true
    };
    var fields = ['profile.business', 'profile.address', 'profile.tel'];
    WifiBusinessSearch = new SearchSource('wifiBusiness', fields, options);
    serverPushedUserInfo = new Meteor.Collection('serverPushedUserInfo');
}
