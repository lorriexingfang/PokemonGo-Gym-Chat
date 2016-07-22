Meteor.startup(function () {
  DEBUG = false;
  if(Meteor.isCordova){
    if(device.platform ==='iOS'){
      Keyboard.shrinkView(true);
      Keyboard.hideFormAccessoryBar(true);
    }
  }

  // 发搭伙的提示说明
  //popup('partnerPopup');
  // 发现的提示说明
  //popup('wifiPopup');
  //reminder for current wifi board place
  //popup('currentWiFiBoard');
  //Initialize LTE flag
  if(window.localStorage.getItem("LTE_hint_flag") == null || window.localStorage.getItem("LTE_hint_flag") == undefined) {
    window.localStorage.setItem("LTE_hint_flag","0");
  }

  getUserLanguage = function() {
    var lang;
    lang = void 0;
    if (navigator && navigator.userAgent && (lang = navigator.userAgent.match(/android.*\W(\w\w)-(\w\w)\W/i))) {
      lang = lang[1];
    }
    if (!lang && navigator) {
      if (navigator.language) {
        lang = navigator.language;
      } else if (navigator.browserLanguage) {
        lang = navigator.browserLanguage;
      } else if (navigator.systemLanguage) {
        lang = navigator.systemLanguage;
      } else {
        if (navigator.userLanguage) {
          lang = navigator.userLanguage;
        }
      }
      lang = lang.substr(0, 2);
    }
    return lang;
  }

  updatePushNotificationToken = function(type,token){
    if(Meteor.userId() && type != undefined && type != '' && token != undefined && token != '' )
      var whichAPP = 'storebbs';
      Meteor.call('updatePushToken',Meteor.userId(),type,token, whichAPP);
  }

    updateDeviceWifi = function(){
    if(!Meteor.isCordova)
      return true;

//    // update 涂鸦的页
//    if(Session.equals('view', 'wifiUserWifi'))
//      Session.set('view', 'wifiIndex');

    if(navigator.connection.type != Connection.WIFI) {
      console.log('##RDBG not wifi connection');
      Session.set('connNetworkStatus', "online-nonwifi");
      return false;
    }
    Session.set('connNetworkStatus', "online-wifi");
    if(Meteor.userId() === null) {
        navigator.wifi.getConnectedWifiInfo(function(wifi) {
            wifi = wifi || {};
            wifi.BSSID = wifi.BSSID || '';
            wifi.BSSID = wifi.BSSID.toLowerCase();
            console.log(wifi);
            wifi.BSSID = formatBSSID(wifi.BSSID);
            Session.set('connectedWiFiInfo', wifi);
            //Session.set('wifiPubWifi-curAPStatus', 'undetermined');
        });
        return true;
    }

    navigator.wifi.getConnectedWifiInfo(function(wifi){
      wifi = wifi || {};
      wifi.BSSID = wifi.BSSID || '';
      wifi.BSSID = wifi.BSSID.toLowerCase();
      console.log(wifi);
      wifi.BSSID = formatBSSID(wifi.BSSID);
      Session.set('connectedWiFiInfo', wifi);

      Meteor.call('updateUserWifiInfo', wifi, function(err){
        if(err) {
          console.log(err);
        }
        else{
          customSubscribe('login_user_wifi');
          customSubscribe('login_user_lan');

//          if(Session.equals('view', 'wifiOffline')){
//            if(getDeviceWifiBusiness() === undefined)
//              Session.set('view', 'wifiPubWifi');
//            else{
//              Session.set('wifiOnlineId', getDeviceWifiBusiness()._id);
//              Session.set('view', 'wifiOnline');
//            }
//          }else if(Session.equals('view', 'wifiUserWifi')){
//            if(getDeviceWifiBusiness() != undefined){
//              Session.set('wifiOnlineId', getDeviceWifiBusiness()._id);
//              Session.set('view', 'wifiOnline');
//            }
//          }
        }
      });
    },function(){
      console.log('获取Wi-Fi信息失败！');
      return false;
    });

    return true;
  }

  safeUpdateDeviceWifi = function() {
    if (updateDeviceWifi() == false) {
        setTimeout(updateDeviceWifi, 5000);
    }
  }

  Session.set('update_wifi_last_time', new Date());
  //updateDeviceWifi();
  $('body').click(function(){
    // 向服务器发送设备的 wifi 信息（10分钟同步一次）
    if(new Date() - Session.get('update_wifi_last_time') >= WIFI_TIMEOUT - 1*60*1000){
      Session.set('update_wifi_last_time', new Date());
      updateDeviceWifi();
    }
  });
  //Meteor.setInterval(updateDeviceWifi, WIFI_TIMEOUT);

  Session.set('updateSignature', 0)
  Deps.autorun(function(){
     if (Session.get('updateSignature')){
         console.log("updateSignature retrigger updateDeviceWifi")
         updateDeviceWifi();
     }
  })

  formatBSSID = function(unformattedBSSID){
    var BSSID = '';
    if (unformattedBSSID != '') {
        var bssid = unformattedBSSID.toLowerCase().split(':')
        for (var i in bssid) {
            var item = bssid[i];
            if (BSSID.length > 0) {
                BSSID += ':';
            }
            if (item.length <= 1) {
                BSSID += "0" + item;;
            } else {
                BSSID += item;
            }
        }
        return BSSID;
    }
  }

  checkIfUseData = function(){
    if ((navigator.connection.type == Connection.CELL_2G)
        || (navigator.connection.type == Connection.CELL_3G)
        || (navigator.connection.type == Connection.CELL_4G)
        || (navigator.connection.type == 'cellular')) {
        return true;
    } else {
        return false;
    }
  }

  checkIfUseWiFi = function(){
    if(!Meteor.isCordova)
        return false;
    if (navigator.connection.type == Connection.WIFI) {
        return true;
    } else {
        return false;
    }
  }

  // 是否已经连接到 wifi
  testDeviceConnectedWifi = function(){
    try{
      if(!Meteor.status().connected)
        return false;
      if(!Meteor.isCordova)
        return false;
      if(navigator.connection.type != Connection.WIFI)
        return false;
      /*if(Meteor.userId() === null)
        return false;
      else if(Meteor.user().profile === undefined)
        return false;
      else if(Meteor.user().profile.wifi === undefined)
        return false;
      */
    }catch(e){return false;}

    return true;
  }

  getConnectedBSSID = function(){
    var bssid;
    if (Meteor.user() && Meteor.user().profile && Meteor.user().profile.wifi) {
      bssid = Meteor.user().profile.wifi.BSSID;
    } else {
      var wifiInfo = Session.get('connectedWiFiInfo');
      bssid = wifiInfo ? wifiInfo.BSSID : '';
    }
    return bssid;
  }
  getDeviceWiFiInfo = function(){
    var bssid = getConnectedBSSID();
    return Wifis.findOne({'BSSID': bssid});
  }

  // 获取 WIFI 商家
  getDeviceWifiBusiness = function(){
    if(!testDeviceConnectedWifi())
      return undefined;

    var bssid = getConnectedBSSID();
    if (bssid == '') {
        console.error("bssid is null.");
        return undefined;
    }
    return Meteor.users.findOne({'business.wifi.BSSID': bssid});
  }

  clearNewCommentsMessage = function(wifiID){
    var chatUser = mongoChatUsers.findOne({
        userId: Meteor.userId(),
        toUserId: wifiID,
        msgTypeEx: 'wifiboard'
    });
    console.log('clearNewCommentsMessage: 1')
    if (chatUser != undefined && chatUser != null) {
        console.log('clearNewCommentsMessage: 2')
        mongoChatUsers.update({
            _id: chatUser._id
        },{
            $set:{
                comments: []
            }
        },function(err){
            console.log("clearNewCommentsMessage: err, "+err);
        });
    }
  }

  clearSysMessageBadge = function(wifiID){
    var chatUser = mongoChatUsers.findOne({
        userId: Meteor.userId(),
        toUserId: wifiID,
        msgTypeEx: 'wifiboard'
    });
    if (chatUser != undefined && chatUser != null) {
        if (chatUser.waitReadCount == 0) {
            //console.log("don't need to clear the system message of this wifi - 2.");
            return;
        }
        mongoChatUsers.update({
            _id: chatUser._id
        },{
            $set:{
                waitReadCount:0
            }
        },function(err){
            console.log(err);
        });
    }
  }

  checkBSSIDRegisterStatus = function() {
      var wifiInfo = Session.get('connectedWiFiInfo');
      var checkBSSIDRegisterStatusOnServer = function(bssid) {
        Meteor.call("isBSSIDRegisteredOnBusinessOrGraffiti", bssid, function(error, result) {
            if (error) {
                console.log('check: remote call isBSSIDRegisteredOnBusinessOrGraffiti failed!!');
                Session.set('wifiPubWifi-curAPStatus', undefined);
            } else if (result.result === true) {
                console.log('check: ##RDBG wifi: wifiPubWifi-curAPStatus regitstered');
                Session.set('wifiPubWifi-curAPStatus', 'registered');
            } else {
                console.log('check: ##RDBG wifi: wifiPubWifi-curAPStatus unregitstered');
                Session.set('wifiPubWifi-curAPStatus', 'unregistered');
            }
        });
      }
      if (wifiInfo) {
        checkBSSIDRegisterStatusOnServer(wifiInfo.BSSID);
      } else {
        navigator.wifi.getConnectedWifiInfo(function(wifi){
            wifi.BSSID = formatBSSID(wifi.BSSID);
            checkBSSIDRegisterStatusOnServer(wifi.BSSID);
        });
      }
  }

  keepAliveIntervalTimer = null;
  keepAliveWithRouter = function() {
    var ajaxRequest = function() {
        $.ajax({
            //url: "http://192.168.98.254/cgi-bin/ip.cgi",
            url: "http://192.168.98.254:2060/wifidog/auth?token=welcome",
            type: 'POST',
            crossDomain: true,
            //data: 'username=admin&password=admin1',
            dataType: 'html',
            success: function(response) {
              console.log("keepAliveWithRouter: suc");
            },
            error: function(err) {
              console.log("keepAliveWithRouter: error");
            }
        });
    }
    if (keepAliveIntervalTimer) {
        clearInterval(keepAliveIntervalTimer);
        keepAliveIntervalTimer = null;
    }
    ajaxRequest();
    keepAliveIntervalTimer = setInterval(function(){
        console.log("keepAliveWithRouter in...");
        ajaxRequest();
    }, 60*1000);
  }

  Deps.autorun(function(){
    var wifi = Session.get('connectedWiFiInfo');
    var setStatus = function() {
        var curWifi = Wifis.findOne({'BSSID': wifi.BSSID});
        if (curWifi) {
            DEBUG && console.log('set wifiPubWifi-curAPStatus regitstered');
            Session.set('wifiPubWifi-curAPStatus', 'registered');
        } else {
            DEBUG && console.log('set wifiPubWifi-curAPStatus unregitstered');
            Session.set('wifiPubWifi-curAPStatus', 'unregistered');
        }
    }
    DEBUG && console.log("Set connectedWiFiInfo, trigger autorun, "+Wifis.find({}).count());
    if (wifi) {
        DEBUG && console.log("wifi="+JSON.stringify(wifi));
        customSubscribe('wifiBSSID', wifi.BSSID, function(type, err) {
            if (type == 'ready') {
                DEBUG && console.log("Ready! wifi.BSSID="+wifi.BSSID);
                setStatus();
            } else {
                DEBUG && console.log('check current wifi failed!! type='+type);
                Session.set('wifiPubWifi-curAPStatus', undefined);
            }
            if (!Session.get('connectedWiFiInfoSubscribe')) {
                Session.set('connectedWiFiInfoSubscribe', true);
            }
        });
        if (Session.get('connectedWiFiInfoSubscribe')) {
            setStatus();
        }
    }
  });

  if (Meteor.isCordova) {
    /**
    * Get registration ID in Cordova
    *
    * @method updateRegistrationID
    * @param {Function} callback
    * @return callback(got_registration_id,registration_id)
    */
	var updateRegistrationID = function (callback){
	  window.plugins.jPushPlugin.getRegistrationID(function(data) {
        console.log("JPushPlugin:registrationID is "+data);
        if(callback === null || callback=== undefined){
          return;
        }
        if(data ===null || data ===undefined){
          callback(false,null);
          return;
        }
		if(data===''){
          console.log('RegisterationID is not set');
          callback(false,null);
		} else {
          callback(true,data);
        }
	  });
    }
    var openNotificationInAndroidCallback = function(data){
      try{
		console.log("JPushPlugin:openNotificationInAndroidCallback");
        console.log(data);
		data=data.replace('"{','{').replace('}"','}');
        var bToObj=JSON.parse(data);
        var message = bToObj.message;
        var extras = bToObj.extras;

        var type = extras["cn.jpush.android.EXTRA"]["type"];
        switch(type){
          case "reply":
            var postId = extras["cn.jpush.android.EXTRA"]["postId"];
            var postType = extras["cn.jpush.android.EXTRA"]["postType"];
            Session.set("postType", postType);
            if(postType == "local_service"){
              //Meteor.subscribe('postInfo', postId);
              Session.set("blackboard_post_id", postId);
//              Meteor.call('page', 'blackboard_detail', function(e){});
              Session.set('view', 'blackboard_detail');
            }else if (postType == 'pub_board'){
              //Meteor.subscribe('postInfo', postId);

              Session.set("partnerId", postId);
              Session.set("blackboard_post_id", postId);
              Session.set("blackborad_footbar_view", "blackboard_footbar_nav");
//              Meteor.call('page', 'blackboard_detail', function(e){});
              Session.set("partner_return_view", 'pub_board');
              Session.set('view', 'partner_detail');
            }else if (postType == 'activity'){
              //Meteor.subscribe('postInfo', postId);
              Session.set('activityId',postId);
              Session.set("partnerId",postId);
              Session.set("blackboard_post_id", postId);
              Session.set("blackborad_footbar_view", "blackboard_footbar_nav");
              Session.set("document.body.scrollTop", document.body.scrollTop);
              Session.set('view', "activity_content");
            }
            break;
          case "chat":
            if(Meteor.user()){
              var toUserId = extras["cn.jpush.android.EXTRA"]["fromUserId"];
              Session.set('chat_home_business', extras["cn.jpush.android.EXTRA"]["isBusiness"])
              Session.set("chat_to_user", undefined)
              Session.set("chat_to_userId", toUserId)
              Session.set("chat_return_view", 'my_message');
              Session.set('view', "chat_home")
            }
            break;
          case "tips":
            // 提示消息不处理
            break;
          case "page":
            var view = extras["cn.jpush.android.EXTRA"]["view"];
            var param = extras["cn.jpush.android.EXTRA"]["param"];
            var isLogin = extras["cn.jpush.android.EXTRA"]["isLogin"];

            if(isLogin && Meteor.user() == null)
              break;
            else if(param){
              for(var key in param)
                Session.set(key, param[key]);
              PUB.page(view);
            }

            break;
          case 'wifiPosts':
            var wifiID = extras["cn.jpush.android.EXTRA"]["wifiID"];
            Template.wifiPubWifi.__helpers.get('open')(wifiID);
            clearSysMessageBadge(wifiID);
            /*Session.set('wifiOnlineId', wifiID)
            Session.set('wifiPubWifi_return', '')
            Session.set('wifiPubWifiIndex-view', 'wifiPubWifiIndexWall')
            Session.set('view', 'wifiPubWifi')*/
        }
      }
      catch(exception){
        console.log("JPushPlugin:openCallback "+exception);
      }
    }
    /**
    * Called when receive push notification from Server and APP is running
    *
    * @method pushNotificationCallback
    * @param {Object} data Push notification context
    */
    var pushNotificationCallback = function(data){
      try{
        console.log("JPushPlugin:receiveMessageInAndroidCallback");
        console.log(data);
        data=data.replace('"{','{').replace('}"','}');
        var bToObj=JSON.parse(data);
        var message = bToObj.message;
        var extras = bToObj.extras;

        console.log(message);
        console.log(extras['cn.jpush.android.MSG_ID']);
        console.log(extras['cn.jpush.android.CONTENT_TYPE']);
        console.log(extras['cn.jpush.android.EXTRA']);
      }
      catch(exception){
        console.log("JPushPlugin:pushCallback "+exception);
      }
    }

    Meteor.startup(function(){
      Session.set('wifis_limit', 10)
      Tracker.autorun(function(){
        //if (Meteor.status().connected){
          $.when(
            customSubscribe('wifiLists', null, Session.get('wifis_limit'), function(type, reason){
                if (type === 'ready') {
                  Session.set('wifis_loading', false);
                  console.log("customSubscribe wifiLists ready.");
                }
              }),
            customSubscribe('chatUsers'),
            console.log('customSubscribe wifiLists ')
          ).done(function(){
            Session.set('wifis_loading', false)
          }).fail(function(){
            Session.set('wifis_loading', false)
          })
        //}
      });

      // 是否能连接到服务器
      Meteor.setTimeout(function(){
        if(!Meteor.status().connected){
          window.plugins.toast.showLongBottom('无法获取数据，请检查网络设置');
        }
      },10000);
      Session.set('uuid',device.uuid);
      document.addEventListener("pause", onPause, false);
      document.addEventListener("resume", onResume, false);
      function onPause(){
        if(device.platform === 'Android' ){
          window.plugins.jPushPlugin.call_native("onPause", new Array(), null);
        }
      }
      function onResume(){
        keepAliveWithRouter();
        if(device.platform === 'Android' ){
          window.plugins.jPushPlugin.call_native("onResume", new Array(), null);
        }

        if(checkIfUseData() && (parseInt(window.localStorage.getItem("LTE_hint_flag")) < 3) ) {
            Blaze.render(Template.lteGuide, document.getElementsByTagName('body')[0]);
        }

        navigator.wifi.getConnectedWifiInfo(function(wifi){
          wifi.BSSID = formatBSSID(wifi.BSSID);
          preWifi = Session.get('connectedWiFiInfo');
          if (preWifi){
            console.log("prewifi:"+preWifi.BSSID + " curewifi:"+ wifi.BSSID)
          }
          console.log("session:" +Session.get('view'));
          if (preWifi == null || preWifi.BSSID != wifi.BSSID) {
            console.log('set connected WIFI info ' + JSON.stringify(wifi));
            Session.set('connectedWiFiInfo', wifi);
            Meteor.call('updateUserWifiInfo', wifi, function(err){
                if(err) {
                  console.log(err);
                }
            });
            /*$.when(
              customSubscribe('wifiBSSID', wifi.BSSID)
            ).done(function(){
              Session.set('connectedWiFiInfoSubscribe', true);
              Meteor.setTimeout(function(){
                Template.wifiPubWifiIndex_AP.__helpers.get('updatePagination')();
              }, 500);
            }).fail(function(){
              Session.set('connectedWiFiInfoSubscribe', true);
            });*/
//            if (Session.equals('view', 'wifiPubWifi') || Session.equals('view', 'wifiUserWifi')) {
//                var wifiInfo = getDeviceWiFiInfo();
//              if (wifiInfo != null) {
//                Session.set('wifiOnlineId', wifiInfo._id);
//                if (Session.equals('wifiPubWifi-view', 'wifiPubWifiIndex')) {
//                  //Session.set('wifiPubWifi-view', 'wifiPubWifiIndex');
//                  Session.set('wifiPubWifi_return', Session.get('view'))
//                  Session.set('view', 'wifiPubWifi');
//                }
//              } else {
//                Session.set('view', 'wifiPubWifi')
//              }
//            }
          }
        }, function(){
          safeUpdateDeviceWifi();
          Session.set('connectedWiFiInfo', null);
          if (parseInt(window.localStorage.getItem("LTE_hint_flag")) >= 3) {
            Session.set('view', 'wifiIndex');
          }
          if (Session.equals('view', 'wifiPubWifi') || Session.equals('view', 'wifiUserWifi')) {
            //Session.set('view', 'wifiPubWifi')
          }
        }
        );
      }
      document.addEventListener("deviceready", onDeviceReady, false);
      function onDeviceReady() {
        if(Cookies.check('display-lang')){
          Session.set('display-lang',Cookies.get('display-lang'))
          TAPi18n.setLanguage(Cookies.get('display-lang'))
        } else {
          Session.set('display-lang','en');
          TAPi18n.setLanguage('en');
        }
        keepAliveWithRouter();
        // 处理 wifi 信息
        navigator.wifi.getConnectedWifiInfo(function(wifi){
          wifi.BSSID = formatBSSID(wifi.BSSID);
          Session.set('connectedWiFiInfo', wifi);
          /*$.when(
            customSubscribe('wifiBSSID', wifi.BSSID)
          ).done(function(){
            Session.set('connectedWiFiInfoSubscribe', true);
          }).fail(function(){
            Session.set('connectedWiFiInfoSubscribe', true);
          });*/
        });

        //show splashing page
        // navigator.splashscreen.hide();
        if (window.localStorage.getItem("firstLog") == null || window.localStorage.getItem("firstLog") == undefined) {
          var flag;
          flag = window.localStorage.getItem("firstLog") == 'first';
          Session.set('isFlag', !flag);
          Session.set('view',"wifiIndex");
        }
        //end
        safeUpdateDeviceWifi();
        document.addEventListener("online", updateDeviceWifi, false);
        document.addEventListener("offline", function(){
//          if(Session.equals('view', 'wifiOnline') || Session.equals('view', 'wifiUserWifi')  || Session.equals('view', 'wifiReport'))
//            Session.set('wifiOffline-showBack', false);
//            Session.set('view', 'wifiIndex');
            console.log("##RDBG network offline");
            Session.set('connNetworkStatus', "offline");
        }, false);

        var onSuccess = function(position) {
          console.log('\nLatitude: '          + position.coords.latitude          + '\n' +
                  'Longitude: '         + position.coords.longitude         + '\n' +
                  'Accuracy: '          + position.coords.accuracy          + '\n' +
                  'Timestamp: '         + position.timestamp                + '\n');
          Session.set('location',{latitude: position.coords.latitude,
              longitude:position.coords.longitude,type:'geo',accuracy:position.coords.accuracy });
          var geoc = new BMap.Geocoder();
          var point = new BMap.Point(Session.get('location').longitude,Session.get('location').latitude);
          geoc.getLocation(point, function(rs){
            if(rs && rs.addressComponents ){
              var addComp = rs.addressComponents;
              if(addComp.city && addComp.city !== ''){
                //alert(addComp.province + ", " + addComp.city + ", " + addComp.district + ", " + addComp.street + ", " + addComp.streetNumber);
                Session.set("location_city",addComp.city);
                if(Session.get("city") === undefined)
                    Session.set("city", addComp.city);
                console.log("location city is " + addComp.city);
                return;
              }
            }
//            var requestUrl = "http://maps.googleapis.com/maps/api/geocode/json?latlng=" + Session.get('location').latitude+','+ Session.get('location').longitude +'&sensor=false';
//            Meteor.http.call("GET",requestUrl,function(error,result){
//              if(result.statusCode === 200){
//                var results = result.content.results;
//                console.log('Result is '+JSON.stringify(result));
//                alert(result);
//              }
//            });
          });
        };
        function onError(error) {
          console.log('code: '    + error.code    + '\n' +
                  'message: ' + error.message + '\n');
        }

        function onErrorGetCurrentPosition(error) {
          console.log('code: '    + error.code    + '\n' +
                  'message: ' + error.message + '\n');

          Meteor.call('getGeoFromConnection',function(err,response ){
            console.log('Geo Location is ' + JSON.stringify(response ));
            var location = Session.get('location');
            if(location && location.type !== 'geo'){
              Session.set('location',{latitude:response.ll[0],longitude:response.ll[1],type:'ip'});
            }
          });
        }


        window.navigator.geolocation.getCurrentPosition(onSuccess, onErrorGetCurrentPosition, { maximumAge: 600000, timeout:60000,enableHighAccuracy :false});
        //window.navigator.geolocation.watchPosition(onSuccess, onError, { maximumAge: 600000, timeout:100000,enableHighAccuracy :false});
        //navigator.geolocation.getCurrentPosition(onSuccess1, onError1);
        // 按钮事件
        document.addEventListener("backbutton", eventBackButton, false); // 返回键

        if(device.platform ==='iOS') {
          console.log('Device platform is ' + device.platform);
          window.onNotificationAPN = function(event) {
            if(event.foreground==='0'){
              // This push notification was received on background
              // When application open, there's need triger local
              // notification again.
              return;
            }
            if ( event.alert ){
              PUB.toast(event.alert);
            }
            if ( event.sound ){
              var snd = new Media(event.sound);
              snd.play();
            }
          }
          window.plugins.pushNotification.register(
            function (result) {
              // Your iOS push server needs to know the token before it can push to this device
              // here is where you might want to send it the token for later use.
              console.log('Got registrationID ' + result);
              Session.set('registrationID',result);
              Session.set('registrationType','iOS');
              window.clearInterval(result);
              updatePushNotificationToken('iOS',result);
            },
            function (error) {
                console.log('No Pushnotification support in this build error = ' + error);
            },
            {
                "badge":"true",
                "sound":"true",
                "alert":"true",
                "ecb": "onNotificationAPN"
            });
        } else if(device.platform === 'Android' ){
          window.plugins.jPushPlugin.receiveMessageInAndroidCallback = pushNotificationCallback;
          window.plugins.jPushPlugin.openNotificationInAndroidCallback = openNotificationInAndroidCallback;
          window.plugins.jPushPlugin.init();
          window.plugins.jPushPlugin.setDebugMode(false);
          window.plugins.jPushPlugin.setBasicPushNotificationBuilder();
          var registerInterval = window.setInterval( function(){
              updateRegistrationID(function(got,registrationID){
              if(got===true){
                console.log('Got registrationID ' + registrationID);
                Session.set('registrationID',registrationID);
                Session.set('registrationType','JPush');
                window.clearInterval(registerInterval);
                updatePushNotificationToken('JPush',registrationID);
              } else {
                console.log("Didn't get registrationID, need retry later");
              }
            })
          },20000 );
        }
      }
      function onConfirm(button){
        if(button===1){
            exitApp();
        }
      }
      function eventBackButton(){
          if (Template.images_view.__helpers.get('isShow')()) {
              Template.images_view.__helpers.get('close')();
          }
          else {
              Template.public_loading_index.__helpers.get('close')();
              window.page.back();
          }

          //navigator.notification.confirm('您确定要退出程序吗？', onConfirm, '退出程序', ['确定','取消']);
      }

      function exitApp() {
          navigator.app.exitApp();
      }
    });
  }else{
    // 方便web下则试所有热点，@feiwu
    Meteor.startup(function(){
      Session.set('wifis_limit', 10)
      Tracker.autorun(function(){
        //if (Meteor.status().connected){
          $.when(
            customSubscribe('wifiLists', null, Session.get('wifis_limit'), function(type, reason){
                if (type === 'ready') {
                  Session.set('wifis_loading', false);
                  console.log("customSubscribe wifiLists ready.");
                }
              }),
            customSubscribe('chatUsers'),
            console.log('customSubscribe wifiLists ')
          ).done(function(){
            Session.set('wifis_loading', false)
          }).fail(function(){
            Session.set('wifis_loading', false)
          })
        //}
      });
      if(!Session.get('view'))
        Session.set('view', 'wifiIndex');
    });
  }
});
