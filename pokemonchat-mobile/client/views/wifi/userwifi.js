/*
此文件已基本弃用，如需修改未加入热点的wifi请修改pubwifi的wifiPubWifiIndex_NoAP template
@feiwu,2015-08-26
*/

checkIfUseWiFi = function(){
    if(!Meteor.isCordova)
        return false;
    else if (navigator.connection.type == Connection.WIFI)
        return true;
    else
        return false;
};


$(window).scroll(function(){
    var scrollTop = $(this).scrollTop()
    var scrollHeight = $(document).height()
    var windowHeight = $(this).height()

    console.log("ALl wifis scroll");
    //console.log("Frank: view="+Session.get('view')+", "+Session.get('wifi-user-wifi-view')+", scrollTop="+scrollTop+", scrollHeight="+scrollHeight+", windowHeight="+windowHeight+", "+Session.get('wifiHistory_limit'))
//    if (Session.equals('view', 'wifiUserWifi')
//       && Session.equals('wifi-user-wifi-view', 'wifiUserWifiFavorite')
//       && Session.get('wififavorite_loaded_count') == Session.get('wifiFavorite_limit')
//       && scrollTop > 0 && scrollTop >= scrollHeight-windowHeight){
//        var limit = Session.get('wifiFavorite_limit') + 10;
//        Session.set('wifiFavorite_limit', limit);
//        Session.set('wifiFavorite_loading', true);
//        $('.up-load-more').html('加载中，请稍候...');
//        $.when(
//            customSubscribe('wifiFavorite', Meteor.userId(), null, limit, function(type, reason){
//                if (type === 'ready') {
//                  Session.set('wifiFavorite_loading', false);
//                  console.log("customSubscribe wifiFavorite ready.");
//                }
//              }
//            )
//        ).done(function() {
//            //$('.up-load-more').html('上拉加载更多...')
//            return console.log("customSubscribe wifiFavorite done.");
//        }).fail(function(){
//            //$('.up-load-more').html('上拉加载更多...')
//            return console.log("customSubscribe wifiFavorite failed.");
//        });
//    }
    console.log("view: " + Session.get('view'))
    console.log("wifiPubWifi-view: " + Session.get('wifiPubWifi-view'))
    console.log("wifiUserWifiNearby_filter: " + Session.get('wifiUserWifiNearby_filter'))

    if (((Session.equals('view', 'wifiPubWifi') && Session.equals('wifiPubWifi-view', 'wifiUserWifiFavorite')))
      && Session.get('wififavorite_loaded_count') == Session.get('wifiFavorite_limit')
      && scrollTop > 0 && scrollTop >= scrollHeight-windowHeight){
        console.log("wifi favorite limit is: ");
        var limit = Session.get('wifiFavorite_limit') + 10;
        Session.set('wifiFavorite_limit', limit);
        Session.set('wifiFavorite_loading', true);
        $('.up-load-more').html('加载中，请稍候...');
    }

    if (((Session.equals('view', 'wifiUserWifi') && Session.equals('wifiPubWifi-view', 'wifiUserWifiNearby') && Session.equals('wifiUserWifiNearby_filter', 'AP') == false) ||
        (Session.equals('view', 'wifiPubWifi') && Session.equals('wifiPubWifi-view', 'wifiUserWifiNearby') && Session.equals('wifiUserWifiNearby_filter', 'AP') == false))
       && Session.get('wifis_loaded_count') == Session.get('wifis_limit')
       && scrollTop > 0 && scrollTop >= scrollHeight-windowHeight){
        var limit = Session.get('wifis_limit') + 10;
        Session.set('wifis_limit', limit);
        Session.set('wifis_loading', true);
        $('.up-load-more').html('加载中，请稍候...');
    }

});

Session.setDefault('wifi-user-wifi-view', 'wifiUserWifiNearby');


//Template.wifiUserWifi.created = function() {
//    if(!Session.equals('view', 'wifiPubWifi'))
//      Session.set('view', 'wifiPubWifi');
//};
Template.wifiUserWifi.rendered = function() {
    popup('notHotspotHint');

    if(Session.equals('wifi-user-wifi-view', 'wifiUserWifiNearby')) {
      $(".userwifi-tags").css({top:'105px'});
    }
    this.$('.main').css('min-height', $('body').height() - this.$('.ad').height() - this.$('.tabs').height() - 48 - 24);
};

Template.wifiUserWifi.helpers({
  wifiName: function() {
    var wifiInfo = getDeviceWiFiInfo();
    if (wifiInfo != null && wifiInfo != undefined) {
        Session.set('wifiOnlineId', wifiInfo._id);
        Session.set('wifiPubWifi_return', '');
        Session.set('view', 'wifiPubWifi');
        //PUB.toast("当前热点刚被其他用户创建，让我们一起来涂鸦吧。")
    }
    if (Meteor.userId() === null) {
      var wifi = Session.get('connectedWiFiInfo');
      if (wifi) {
        return wifi.SSID.replace('"', '').replace('"', '');
      }
      return '欢迎加入WiFi朋友';
   } else if (Meteor.user() === void 0 || Meteor.user().profile === void 0 || Meteor.user().profile.wifi === void 0 || Meteor.user().profile.wifi.SSID === void 0) {
      return '欢迎加入WiFi朋友';
    } else {
      var wifi = Session.get('connectedWiFiInfo');
      if (wifi) {
        return wifi.SSID.replace('"', '').replace('"', '');
      }
      //return Meteor.user().profile.wifi.SSID.replace('"', '').replace('"', '');
    }
  },
  checkIfUseWiFi: function(){
    if(!Meteor.isCordova)
        return false;
    if (navigator.connection.type == Connection.WIFI) {
        return true;
    } else {
        return false;
    }
  },
  template: function() {
    return Session.get('wifi-user-wifi-view');
  },
  isLocal: function() {
    return Session.equals('wifi-user-wifi-view', 'wifiUserWifiLocal');
  },
  isHistory: function() {
    return Session.equals('wifi-user-wifi-view', 'wifiUserWifiHistory');
  },
  isFavorite: function() {
    return Session.equals('wifi-user-wifi-view', 'wifiUserWifiFavorite');
  },
  isNearby: function() {
    return Session.equals('wifi-user-wifi-view', 'wifiUserWifiNearby');
  },
  isAP: function() {
    return Session.equals('wifi-user-wifi-view', 'wifiUserWifiAP');
  },
  isCurrentWiFiFriend: function() {
    /*if(!Meteor.isCordova)
      return false;
    else if (navigator.connection.type != Connection.WIFI)
      return false;
    else if(Template.wifiUserWifi.__helpers.get('isNearby')())
      return false;

    var wifi = Session.get('connectedWiFiInfo');

    if (wifi) {
      if (Wifis.findOne({BSSID: wifi.BSSID})) {
        //$("ul.userwifi-tags").css('top', '105px');
        return false;
      }
      else {
        return true;
      }
    }

    return false;*/
    console.log("1, wifiPubWifi-curAPStatus="+Session.get('wifiPubWifi-curAPStatus'))
    if (Session.equals('wifiPubWifi-curAPStatus', 'unregistered')) {
        return true;
    } else {
        return false;
    }
  },
  getTag: function() {
    var platform_type;

    if (Meteor.isCordova) {
      //is android platform
      platform_type = true;
    }

    if (checkIfUseWiFi() && platform_type) {
      return 'tag-4';
    } else {
      return 'tag-3';
    }
  },
  useWiFi: function() {
    if (checkIfUseWiFi()) {
      return true;
    } else {
      return false;
    }
  },
  getWiFiStatus: function() {
    var status = Session.get('wifiPubWifi-curAPStatus');
    console.log('2, getWiFiStatus..., status='+status);
    if (status == undefined) {
      return false;
    } else {
      return true;
    }
  },
  is_android: function() {
    if (Meteor.isCordova) {
      return device.platform === 'Android';
    } else {
      return false;
    }
  },
  isLogin: function() {
    if (Meteor.userId()) {
        return true;
    } else {
        return false;
    }
  }
});

Template.wifiUserWifi.events({
  'click .userwifi-tags li': function(e) {
    /*if(e.currentTarget.id == 'wifiUserWifiNearby'){
      $("#wifiTips").hide();
      $(".userwifi-tags").css({top:'105px'})
    }else{
      $("#wifiTips").show();
      $(".userwifi-tags").css({top:'145px'})
    }*/
    return Session.set('wifi-user-wifi-view', e.currentTarget.id);
  },
  'click .tips': function() {
    $("#wifiTips").hide();
    $(".userwifi-tags").css({top:'105px'})
    Session.set('wifi-user-wifi-view', 'wifiUserWifiNearby');
  },
  'click #addHotspot': function(){
    if (Meteor.userId() === null) {
        PUB.toast('注册登录后才能创建哦，赶快注册吧！');
        Session.set('view', 'login');
        return;
    }
    Session.set("public_upload_index_images", []);
    Session.set('view', 'wifiAddWifi');
  }
});

Template.wifiUserWifiLocal.helpers({
  users: function() {
    var item, users, bssid, _i, _len, _ref;
    users = [];
    bssid = getConnectedBSSID();
    if (!Wifis.findOne({BSSID: bssid})) {
        return users;
    }

    customSubscribe('userInfoByBSSID', bssid);
    _ref = Meteor.users.find({
      'profile.wifi.BSSID': bssid
    }).fetch();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      if (item._id == Meteor.userId()) {
        users.unshift(item);
      } else if (item.profile.wifi.status === 'online') {
        users.push(item);
      }
    }
    users.sort(function(a, b) {
        return new Date(b.updateTime) - new Date(a.updateTime);
    });
    return users;
  },
  time: function(val) {
    var now;
    now = new Date();
    return GetTime0(now - val);
  },
  name: function(obj) {
    if (obj.profile.nike) {
      return obj.profile.nike;
    } else {
      return obj.username;
    }
  },
  picture: function(obj) {
    if (obj.profile.picture) {
      return obj.profile.picture;
    } else {
      return '/userPicture.png';
    }
  },
  noUsers: function(obj) {
    return obj.length <= 0;
  }
});

Template.wifiUserWifiLocal.events({
  'click .my_message_guest': function() {
    $(".my_message_guest").hide();
    $("#myloading").show();
    window.setTimeout(function(){
      $(".my_message_guest").show();
      $("#myloading").hide();
    },1000)
    Session.set('view',"wifiUserWifi")
  },
  'click .wifi-user li': function(e) {
    if (e.currentTarget.id == Meteor.userId()) {
      PUB.toast('不能和自己聊天，去附近有WIFI朋友的地方逛逛吧～')
      return;
    }
    Session.set("chat_to_userId", e.currentTarget.id);
    Session.set('chat_return_view', Session.get("view"));
    return PUB.page("chat_home");
  }
});

Template.wifiUserWifiHistory.rendered = function() {
  $('.wifi-user').css('min-height', $(window).height()-48-45-50-10);
};

Template.wifiUserWifiHistory.helpers({
  trunc_str: function(len, pass) {
    if (pass.length > len)
        pass = pass.substring(0, len) + '...';
    return pass;
  },
  wifiHistory: function(obj) {
    var wifiHistory = WifiHistory.find({userId: Meteor.userId()}, {sort: {accessAt: -1}, limit:Session.get('wifiHistory_limit')}).fetch();
    console.log("wifiHistory.length="+wifiHistory.length);
    Session.set('wifihistory_loaded_count', wifiHistory.length);
    return wifiHistory;
  },
  getWifiInfo: function(wifiID) {
    customSubscribe('wifiBSSID', wifiID)
    return Wifis.findOne({'_id': wifiID})
  },
  time: function(val) {
    now = new Date();
    return GetTime0(now - val);
  },
  noUsers: function(obj) {
    if (obj != undefined)
      return obj.length <= 0;
    else {
      return true;
    }
  },
  getWifiPicture: function(latestPicture) {
    if (latestPicture == undefined) {
        return 'http://localhost.com/fZ8PtzM4rmYJKpCaz_1447184412955_cdv_photo_001.jpg';
    } else {
        return latestPicture;
    }
  },
  get_distance: function(val) {
    var location = Session.get('location')

    if(val !== undefined && val.location !== undefined && location !== undefined)
      return distance(location.longitude, location.latitude, val.location.coordinates[0], val.location.coordinates[1])
    else
      return ''
  },
  has_more_data: function() {
    if (Session.get('wifihistory_loaded_count') == undefined || Session.get('wifihistory_loaded_count') <= 0) {
        return false;
    } else if (Session.get('wifiHistory_loading')) {
        return true;
    } else
        if (Session.get('wifihistory_loaded_count') == Session.get('wifiHistory_limit')) {
            return true;
        } else {
            return false;
        }
  },
  isLogin: function() {
    if (Meteor.userId()) {
        return true;
    } else {
        return false;
    }
  },
  gec: function(id, obj) {
    var geoc, point;
    if ((obj != null) && (obj.address != null) && obj.address !== '') {
      return obj.address.replace('"', '').replace('"', '');
    } else {
      if ((obj != null) && (obj.coordinates != null) && (obj.coordinates[0] != 0 && obj.coordinates[1] != 0 )) {
        geoc = new BMap.Geocoder();
        point = new BMap.Point(obj.coordinates[0], obj.coordinates[1]);
        geoc.getLocation(point, function(rs) {
          var addComp, requestUrl;
          if (rs && rs.addressComponents) {
            addComp = rs.addressComponents;
            if (addComp.city && addComp.city !== '') {
              console.log('1' + addComp.province + ", " + addComp.city + ", " + addComp.district + ", " + addComp.street + ", " + addComp.streetNumber);
              //Session.set("wifiBoardLocation", addComp.province + addComp.city + addComp.district + addComp.street);
              obj.address = addComp.province + addComp.city + addComp.district + addComp.street;
              return WifiHistory.update({
                _id: id
              }, {
                $set: {
                  'location': obj
                }
              }, function(err, number) {
                if (err) {
                  return console.log('update location ' + err);
                }
              });
            } else {
              requestUrl = "http://maps.googleapis.com/maps/api/geocode/json?latlng=" + obj.coordinates[1] + ',' + obj.coordinates[0] + '&sensor=false';
              return Meteor.http.call("GET", requestUrl, function(error, result) {
                var results;
                if (result.statusCode === 200) {
                  results = result.data.results;
                  if (results.length > 1) {
                    //Session.set("wifiBoardLocation", JSON.stringify(results[1].formatted_address));
                    console.log("gooleappis" + JSON.stringify(results[1].formatted_address));
                    obj.address = JSON.stringify(results[1].formatted_address);
                    return WifiHistory.update({
                      _id: id
                    }, {
                      $set: {
                        'location': obj
                      }
                    }, function(err, number) {
                      if (err) {
                        return console.log('update location ' + err);
                      }
                    });
                  }
                }
              });
            }
          }
        });
      }
      return '定位中';
    }
  }
});

Template.wifiUserWifiHistory.events({
  'click .ap-list li': function() {
    //Session.set('wifiPubWifi-view','wifiPubWifiIndex');
    Session.set('wifiOnlineId', this._id);
    //Session.set('wifiOnlineId', this.wifiID);
    Session.set('wifiPubWifi_return', Session.get('view'))
    Session.set('view', "wifiPubWifi");
  }
});
/*
Template.wifiUserWifiNearby.created = function() {
  Session.set('wifis_limit', 5)
}
*/
Template.wifiUserWifiNearby.rendered = function() {
  //Session.set('wifiUserWifiNearby_filter', 'AP');
  //Session.set('wifiPubWifi-view', 'wifiUserWifiNearby')
  $('.wifi-user').css('min-height', $(window).height()-48-45-50-10);
};

Template.wifiUserWifiNearby.helpers({
  trunc_str: function(len, pass) {
    if (pass.length > len)
        pass = pass.substring(0, len) + '...';
    return pass;
  },
  isFavorite: function(id){
    return WifiFavorite.findOne({userId: Meteor.userId(), wifiID: this._id}) != undefined;
  },
  isAP: function(){
    return Session.equals('wifiUserWifiNearby_filter', 'AP');
  },
  isPwd: function(passwd) {
    if(passwd)
      return true;
    else
      return false;
  },
  wifis: function(obj) {
    try{
      var geolocation = Session.get('location');
      var lnglat = geolocation?[geolocation.longitude, geolocation.latitude]:[0, 0];
      //wifis = Wifis.find({"location.coordinates":{$near:lnglat,  $maxDistance: 2000000 }},{sort: {LastActiveTime: -1}}).fetch()
      limit = Session.get('wifis_limit')
      wifis = Wifis.find({}, {limit: limit, sort: {LastActiveTime: -1}}).fetch()
      Session.set('wifis_loaded_count', wifis.length);
      console.log('wifis_loaded_count:'+ wifis.length);
    }catch(e){
      console.log('请使用“Wifis.ensureIndex({"location.coordinates": "2d"})”为Wifis的location建立索引')
      return []
    }
    return wifis;
  },
  has_more_data: function() {
    if (Session.get('wifis_loaded_count') == undefined || Session.get('wifis_loaded_count') <= 0) {
        return false;
    } else if (Session.get('wifis_loading')) {
        return true;
    } else
        if (Session.get('wifis_loaded_count') == Session.get('wifis_limit')) {
            return true;
        } else {
            return false;
        }
  },
  time: function(val) {
    now = new Date();
    return GetTime0(now - val);
  },
  noUsers: function(obj) {
    if (obj != undefined)
      return obj.length <= 0;
    else {
      return true;
    }
  },
  getWifiPicture: function(latestPicture) {
    if (latestPicture == undefined) {
        return 'http://localhost.com/fZ8PtzM4rmYJKpCaz_1447184412955_cdv_photo_001.jpg';
    } else {
        return latestPicture;
    }
  },
  get_distance: function(val) {
    var location = Session.get('location')

    if(val !== undefined && val.location !== undefined && location !== undefined)
      return distance(location.longitude, location.latitude, val.location.coordinates[0], val.location.coordinates[1])
    else
      return ''
    },
  gec: function(id, obj) {
    var geoc, point;
    if ((obj != null) && (obj.address != null) && obj.address !== '') {
      return obj.address.replace('"', '').replace('"', '');
    } else {
      if ((obj != null) && (obj.coordinates != null) && (obj.coordinates[0] != 0 && obj.coordinates[1] != 0 )) {
        geoc = new BMap.Geocoder();
        point = new BMap.Point(obj.coordinates[0], obj.coordinates[1]);
        geoc.getLocation(point, function(rs) {
          var addComp, requestUrl;
          if (rs && rs.addressComponents) {
            addComp = rs.addressComponents;
            if (addComp.city && addComp.city !== '') {
              console.log(addComp.province + ", " + addComp.city + ", " + addComp.district + ", " + addComp.street + ", " + addComp.streetNumber);
              //Session.set("wifiBoardLocation", addComp.province + addComp.city + addComp.district + addComp.street);
              obj.address = addComp.province + addComp.city + addComp.district + addComp.street;
              return Wifis.update({
                _id: id
              }, {
                $set: {
                  'location': obj
                }
              }, function(err, number) {
                if (err) {
                  return console.log('update location ' + err);
                }
              });
            } else {
              requestUrl = "http://maps.googleapis.com/maps/api/geocode/json?latlng=" + obj.coordinates[1] + ',' + obj.coordinates[0] + '&sensor=false';
              return Meteor.http.call("GET", requestUrl, function(error, result) {
                var results;
                if (result.statusCode === 200) {
                  results = result.data.results;
                  if (results.length > 1) {
                    //Session.set("wifiBoardLocation", JSON.stringify(results[1].formatted_address));
                    console.log("gooleappis" + JSON.stringify(results[1].formatted_address));
                    obj.address = JSON.stringify(results[1].formatted_address);
                    return Wifis.update({
                      _id: id
                    }, {
                      $set: {
                        'location': obj
                      }
                    }, function(err, number) {
                      if (err) {
                        return console.log('update location ' + err);
                      }
                    });
                  }
                }
              });
            }
          }
        });
      }
      return '定位中';
    }
  }
});

function increaseAccessNumber(wifiId) {
    if (!wifiId)
        return;

    Wifis.update({_id: wifiId}, {$inc: {visitCount: 1}});

    var usr = Meteor.user();
    if (usr) {
        var visitors = [];
        wifi = Wifis.findOne({_id: wifiId});
        var visitor = {userId: usr._id, userPicture: usr.profile.picture, visitTime: new Date()};

        visitors.push(visitor);
        try {
            var visitor_num = 0;
            if (wifi.visitors) {
                for (var i = 0; i < wifi.visitors.length; i++) {
                    if (wifi.visitors[i].userId != usr._id) {
                        visitors.push(wifi.visitors[i]);
                        visitor_num++;
                        if (visitor_num >= 4)
                            break;
                    }
                }
            }
        }
        catch (ex) {}
        Wifis.update({_id: wifiId}, {$set: {visitors: visitors}});
    }
}

Template.wifiUserWifiNearby.events({
  'click .btn-tuya': function(e){
    e.stopPropagation();
    if (Meteor.userId() === null){
      PUB.toast('请登录后操作！');
      return;
    }

    Template.wifiPubWifi.__helpers.get('open')(this._id, true);
    clearSysMessageBadge(this._id);
  },
  'click .btn-cancel-favorite': function(e){
    e.stopPropagation();
    if (Meteor.userId()){
      var favorite = WifiFavorite.findOne({userId: Meteor.userId(), wifiID: this._id});
      if(favorite === undefined)
        window.PUB.toast('您还没有收藏这个小店！');
      else {
        WifiFavorite.remove(favorite._id, function(err){
          if(err)
            window.PUB.toast('操作失败，请重试！');
        });
        var wifiName = favorite ? favorite.nike : 'NO WIFI NAME';
        trackEvent("取消收藏小店", "Unfavorite the store: "+wifiName+", id is "+this._id);
      }
    }
  },
  'click .btn-add-favorite': function(e){
    e.stopPropagation();
    if (Meteor.userId()){
      var wifis = Wifis.findOne({'_id': this._id});
      var wifiUser = {};

      for (var key in wifis){if(key == '_id'){wifiUser.wifiID = wifis._id;}else{wifiUser[key] = wifis[key];}}
      wifiUser.userId = Meteor.userId();
      wifiUser.accessAt = new Date();
      WifiFavorite.insert(wifiUser, function(err){
        if(err && err.error != 403){
          console.log(err);
          window.PUB.toast('收藏失败！');
        }
      });
      var wifiName = wifis ? wifis.nike : 'NO WIFI NAME';
      trackEvent("收藏小店", "Favorite the store: "+wifiName+", id is "+this._id);
    } else {
      window.PUB.toast('请登录后操作！');
    }
  },
  'click .tips': function(){
    if(Session.equals('wifiUserWifiNearby_filter', 'AP'))
      Session.set('wifiUserWifiNearby_filter', 'WIFI');
    else
      Session.set('wifiUserWifiNearby_filter', 'AP');
  },
  'click .ap-list-detail': function(e) {
    Template.wifiPubWifi.__helpers.get('open')(this._id)
    increaseAccessNumber(this._id);
    clearSysMessageBadge(this._id);
    /*
    customSubscribe('wifiHistory', Meteor.userId(), this._id);
    if (Meteor.userId()) {
      var wifiUser = WifiHistory.findOne({wifiID:this._id, userId:Meteor.userId()});
      if (wifiUser) {
        WifiHistory.update({_id: wifiUser._id}, {$set: {accessAt:new Date()}});
      } else {
        var wifiUser = {};
        for (var key in this) {
          if (key == '_id') {
            wifiUser.wifiID = this._id;
          } else {
            wifiUser[key] = this[key];
          }
        }
        wifiUser.userId = Meteor.userId();
        wifiUser.accessAt = new Date();
        //console.log("wifiUser = "+JSON.stringify(wifiUser));
        WifiHistory.insert(wifiUser);
      }
      increaseAccessNumber(this._id);
    }
    */
  }
})

function connectWifi(ssid, passwd) {
    console.log("connectWifi, password: " + passwd + ", ssid: " + ssid);

    var wifiObj = WifiWizard.formatWPAConfig(ssid, passwd);
    if (!wifiObj) {
        console.log("fail to format wifi config");
        return;
    }

    WifiWizard.addNetwork(wifiObj, function(suc_str){
        console.log('addNetwork suc: ' + suc_str);
        WifiWizard.connectNetwork(ssid, function(suc_str){
            console.log("connect ssid suc: " + suc_str);
        }, function(fail_str){
            console.log("connect ssid fail: " + fail_str);
        });
    }, function(fail_str){
        console.log('addNetwork fail: ' + fail_str);
    });
}

Template.wifiUserWifiAP.rendered = function() {
  $('#scanHotspot').click()
//  this.$("#wifiPasswordModal").css('bottom', '200px');
//  this.$("#wifiPasswordModal").css('top', 'auto');
};

Template.wifiUserWifiAP.events({
  'click #checkHotspot': function(evt, t){
    var cur_ssid = Session.get('ConnectedSSID');
    var wfs = NearbyWifiLists.find({}, {sort: {level: -1}}).fetch();
    for (var item in wfs){
        var wf = Wifis.findOne({BSSID:wfs[item].BSSID});
        if (wf && wf.passwd) {
            if (wf.SSID == cur_ssid || wf.SSID == '"'+cur_ssid+'"')
                PUB.toast("已经连接到公共Wifi " + wf.SSID);
            else {
                connectWifi(wf.SSID, wf.passwd);
                PUB.toast("正在连接 " + wf.SSID);
            }
            return;
        }
    }
    PUB.toast("附近未发现公共Wifi!");
  },
  'click #scanHotspot': function(){
    WifiWizard.getCurrentSSID(function(result){
        //console.log("WifiWizard.getConnectedSSID : "+result.replace(/\"/g, ''));
        Session.set('ConnectedSSID', result.replace(/\"/g, ''));
    }, function(err){
        console.log("WifiWizard.getConnectedSSID err: "+err);
    });
    WifiWizard.startScan(function(){
      console.log("scan start suc");
    }, function(){
      console.log("scan start fail");
    });

    WifiWizard.getScanResults({numLevels: 4}, function(infos){
        //console.log("wifi "+ JSON.stringify(infos));
        if (infos != undefined && infos != null){
          NearbyWifiLists.remove({});
          //console.log("NearbyWifiLists count " + NearbyWifiLists.find().count());
          for (var item in infos){
            if (infos[item].SSID != '') {
              NearbyWifiLists.insert(infos[item]);
            }
          }
        }
    });

  },
  'click #wifi-password-btnsave': function(evt, t) {
      var passwd = t.$('#wifi-password').val();
      var ssid = Session.get('connectingwifi');
      if (!passwd) {
        PUB.toast("Wifi密码不能为空!");
        return;
      }
      connectWifi(ssid, passwd);
      PUB.toast("正在连接Wifi " + ssid);
      t.$("#wifiPasswordModal").modal('hide');
  },
  'click #wifi-password-btncancel': function(evt, t) {
      console.log("cancel button clicked");
  },
//  'focus #wifi-password': function(evt, t) {
//    t.$("#wifiPasswordModal").css('bottom', '0px');
//  },
//  'blur #wifi-password': function(evt, t) {
//    t.$("#wifiPasswordModal").css('bottom', '200px');
//  },
  'click div.wifi-ap-list ul li': function(evt, t) {
      console.log("##RDBG wifi ap clicked, connect this ap, ssid: " + this.SSID);
      var cur_wf = Session.get('ConnectedSSID');
      if (cur_wf == this.SSID) {
        PUB.toast("已经连接" + cur_wf);
        return;
      }

      var wifi = Wifis.findOne({BSSID:this.BSSID});
      if (wifi) {
        connectWifi(this.SSID, wifi.passwd);
        PUB.toast("正在连接Wifi " + this.SSID);
        return;
      }

      Session.set('connectingwifi', this.SSID);
      t.$('#wifi-password').val('');
      t.$("#wifiPasswordModal").modal();
  },
})

Template.wifiUserWifiAP.helpers({
  isConnected: function(SSID) {
    //console.log("SSID: "+ SSID);
    if (SSID === Session.get('ConnectedSSID')) {
      return true;
    } else {
      return false;
    }
  },
  CurrentSSID: function() {
    return Session.get('ConnectedSSID');
  },
  wifiHotspots: function(){
    return NearbyWifiLists.find().fetch();
  },
  wifiLevel: function(item){
    var img = ["/wifi/001.png","/wifi/002.png","/wifi/003.png","/wifi/004.png"];
    return img[item];
  },
  connectingSSID: function() {
    return Session.get('connectingwifi');
  },
})

Template.wifiUserWifiFavorite.rendered = function() {
  $('.wifi-user').css('min-height', $(window).height()-48-45-50-10);
};

Session.setDefault('wifiFavorite_limit', 10)
Template.wifiUserWifiFavorite.helpers({
  trunc_str: function(len, pass) {
    if (pass.length > len)
        pass = pass.substring(0, len) + '...';
    return pass;
  },
  wifiFavorite: function(obj) {
    var wifiFavorite = WifiFavorite.find({userId: Meteor.userId()}, {sort: {accessAt: -1}, limit:Session.get('wifiFavorite_limit')}).fetch();
    console.log("wifiFavorite.length="+wifiFavorite.length);
    Session.set('wififavorite_loaded_count', wifiFavorite.length);
    Session.set('wifiFavorite_loading', false);
    return wifiFavorite;
  },
  getWifiInfo: function(wifiID) {
    customSubscribe('wifiBSSID', wifiID)
    return Wifis.findOne({'_id': wifiID})
  },
  time: function(val) {
    now = new Date();
    return GetTime0(now - val);
  },
  noUsers: function(obj) {
    if (obj != undefined)
      return obj.length <= 0;
    else {
      return true;
    }
  },
  getWifiPicture: function(latestPicture) {
    if (latestPicture == undefined) {
        return 'http://localhost.com/fZ8PtzM4rmYJKpCaz_1447184412955_cdv_photo_001.jpg';
    } else {
        return latestPicture;
    }
  },
  get_distance: function(val) {
    var location = Session.get('location')

    if(val !== undefined && val.location !== undefined && location !== undefined)
      return distance(location.longitude, location.latitude, val.location.coordinates[0], val.location.coordinates[1])
    else
      return ''
  },
  has_more_data: function() {
    if (Session.get('wififavorite_loaded_count') == undefined || Session.get('wififavorite_loaded_count') <= 0) {
        return false;
    } else if (Session.get('wifiFavorite_loading')) {
        return true;
    } else
        if (Session.get('wififavorite_loaded_count') == Session.get('wifiFavorite_limit')) {
            return true;
        } else {
            return false;
        }
  },
  isLogin: function() {
    if (Meteor.userId()) {
        return true;
    } else {
        return false;
    }
  },
  gec: function(id, obj) {
    var geoc, point;
    if ((obj != null) && (obj.address != null) && obj.address !== '') {
      return obj.address.replace('"', '').replace('"', '');
    } else {
      if ((obj != null) && (obj.coordinates != null) && (obj.coordinates[0] != 0 && obj.coordinates[1] != 0 )) {
        geoc = new BMap.Geocoder();
        point = new BMap.Point(obj.coordinates[0], obj.coordinates[1]);
        geoc.getLocation(point, function(rs) {
          var addComp, requestUrl;
          if (rs && rs.addressComponents) {
            addComp = rs.addressComponents;
            if (addComp.city && addComp.city !== '') {
              console.log('1' + addComp.province + ", " + addComp.city + ", " + addComp.district + ", " + addComp.street + ", " + addComp.streetNumber);
              //Session.set("wifiBoardLocation", addComp.province + addComp.city + addComp.district + addComp.street);
              obj.address = addComp.province + addComp.city + addComp.district + addComp.street;
              return WifiFavorite.update({
                _id: id
              }, {
                $set: {
                  'location': obj
                }
              }, function(err, number) {
                if (err) {
                  return console.log('update location ' + err);
                }
              });
            } else {
              requestUrl = "http://maps.googleapis.com/maps/api/geocode/json?latlng=" + obj.coordinates[1] + ',' + obj.coordinates[0] + '&sensor=false';
              return Meteor.http.call("GET", requestUrl, function(error, result) {
                var results;
                if (result.statusCode === 200) {
                  results = result.data.results;
                  if (results.length > 1) {
                    //Session.set("wifiBoardLocation", JSON.stringify(results[1].formatted_address));
                    console.log("gooleappis" + JSON.stringify(results[1].formatted_address));
                    obj.address = JSON.stringify(results[1].formatted_address);
                    return WifiFavorite.update({
                      _id: id
                    }, {
                      $set: {
                        'location': obj
                      }
                    }, function(err, number) {
                      if (err) {
                        return console.log('update location ' + err);
                      }
                    });
                  }
                }
              });
            }
          }
        });
      }
      return '定位中';
    }
  }
});

Template.wifiUserWifiFavorite.events({
  'click .btn-tuya': function(e){
    e.stopPropagation();
    if (Meteor.userId() === null){
      PUB.toast('请登录后操作！');
      return;
    }

    Template.wifiPubWifi.__helpers.get('open')(this._id, true);
    clearSysMessageBadge(this._id);
  },
  'click .btn-remove': function(e){
    e.stopPropagation();
    if (Meteor.userId()){

      var favorite = WifiFavorite.findOne({userId: Meteor.userId(), wifiID: this._id});
      if(favorite === undefined)
        window.PUB.toast('您还没有收藏这个小店！');
      else {
        WifiFavorite.remove(favorite._id, function(err){
          if(err)
            window.PUB.toast('操作失败，请重试！');
          else
            window.PUB.toast('删除成功！');
        });
      }
    }
  },
  'click .ap-list>li': function(e) {
    e.stopPropagation();
    Template.wifiPubWifi.__helpers.get('open')(this._id);
    clearSysMessageBadge(this._id);
  }
});
