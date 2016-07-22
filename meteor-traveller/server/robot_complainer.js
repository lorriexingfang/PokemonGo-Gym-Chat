if (Meteor.isServer) {
//    var complaining_name = 'rtc_zhang3';
    var complaining_name = 'qwxqwsean';
    var complaining_userid = null;
    //var complaining_nickname = '吐槽张老三';
    var complaining_nickname = 'qwxqwsean';
    var complaining_interval = 1000*60*60*24; //24 hours
    var complains = [
        '老板咋又脑洞大开了呢？',
        '好想去BAT上班啊，扫地都行！',
        '大家来评评公司有哪些帅哥和美女',
        '大家来说说公司BT的老板有哪些',
        '我旁边隔间里的哥们老放屁，熏死人了，求解！',
        '美女今天穿得很漂亮啊！',
        '饿了饿了，觅食去的有吗？',
        '刚上班就想下班了怎么办？'
    ];
    
    var profile = {
      createdAt: new Date(),
      picture: '/userPicture.png',
      isVip: 0,
      isAdmin: 0,
      isTestUser: false,
      isBusiness: 0,
      isSystem: true,
      isReply: false
    };
    
    checkComplainerAccount = function() {        
        //complaining account
        if(Meteor.users.find({'username': complaining_name}).count() <= 0) {
            profile.nike = complaining_nickname;
            profile.picture = 'http://bos.youzhadahuo.com/NCauQCC2gy8Faw7Jz_1433497829161.jpg';
            complaining_userid = Accounts.createUser({username: complaining_name, password: (new Mongo.ObjectID())._str, profile: profile});
        }
        else {
            complaining_userid = Meteor.users.findOne({'username': complaining_name})._id;
        }
        console.log("##RDBG checkComplainerAccount id: " + complaining_userid);
    };
    
    addAutoComplain = function() {        
        var wifi_cursor = Wifis.find({}, {sort: {LastActiveTime: -1}, limit: 10});
        wifi_cursor.forEach(function (wifi) {
            var idx = Math.floor((Math.random() * complains.length));
            var post = {
                userId: complaining_userid,
                userName: complaining_nickname,
                userPicture: '/userPicture.png',
                text: complains[idx],
                createTime: new Date(),
                images: [],
                wifiID: wifi._id
            };
            WifiPosts.insert(post);
        });        
        
        Meteor.setTimeout(addAutoComplain, complaining_interval);
    };
    
    //Meteor.startup(function () {
    //    console.log("##RDBG complaining robot startup");
    //    Meteor.setTimeout(checkComplainerAccount, 1000*60);
    //    Meteor.setTimeout(addAutoComplain, 1000*60*5);
    //});
}