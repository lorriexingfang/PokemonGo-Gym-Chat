if (Meteor.isServer){
    //mongoPosts = new Mongo.Collection('posts');
    //Posts = mongoPosts;//new Ground.Collection(mongoPosts);
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
    //mongoChatUsers = new Meteor.Collection("chatUsers");
    //ChatUsers = mongoChatUsers;//new Ground.Collection(mongoChatUsers);//聊天的最近聊系人
    var mongoPhotos = new Mongo.Collection("photos");
    Photos = mongoPhotos;//new Ground.Collection(mongoPhotos);//用户相册
    var mongoEvents = new Mongo.Collection("events");
    Events = mongoEvents;
    Users = Meteor.users;


    Meteor.methods({
        'getStatics':function(){
            var total_ad_posts = Posts.find({type: 'ad'}).count();
            var total_posts = Posts.find().count();
            var total_localservice_posts = Posts.find({type: 'local_service'}).count();
            var total_pubboard_posts = Posts.find({type: 'pub_board'}).count();
            var total_notes_posts = Posts.find({type: 'notes'}).count();
            var total_partner_count = Partner.find().count();
            //var total_WiFi_merchant = Users.find({'profile.isBusiness':1}).count();
            var total_WiFi_merchant = Users.find({'profile.isBusiness':1}).count();
            var total_pending_WiFi_merchant = Users.find({'profile.isBusiness':2}).count();
            var total_chat_records = Chats.find().count();
            var total_register_generalusers = Users.find({'profile.isBusiness':0}).count();
            var total_wechat_users = Users.find({'services.weixin':{$exists: true}}).count();
            var total_register_users = Users.find().count();
            var total_vip_users = Users.find({'profile.isVip':1}).count();

            var total_comments = 0;
            var commentsRecords = Posts.find().fetch();
            for (var i in commentsRecords) {
                if (commentsRecords[i].replys) {
                    total_comments += commentsRecords[i].replys.length;
                }
            }
            return {
                total_posts:total_posts,
                total_ad_posts: total_ad_posts,
                total_localservice_posts: total_localservice_posts,
                total_pubboard_posts: total_pubboard_posts,
                total_notes_posts: total_notes_posts,
                total_comments: total_comments,
                total_partner_count:total_partner_count,
                total_pending_WiFi_merchant: total_pending_WiFi_merchant,
                total_WiFi_merchant:total_WiFi_merchant,
                total_chat_records:total_chat_records,
                total_register_generalusers:total_register_generalusers,
                total_wechat_users:total_wechat_users,
                total_register_users:total_register_users,
                total_vip_users:total_vip_users,
            };
        }
    });
}