Meteor.startup(function () {
  var sessionSet = Package['reactive-dict'].ReactiveDict.prototype.set;
  showLoading = function(){
    Template.public_loading_index.__helpers.get('show')();
    Meteor.setTimeout(function(){closeLoading();}, 5000);
  }
  closeLoading = function(){Template.public_loading_index.__helpers.get('close')();};
  loadData = function(key, value){
    if(key === 'view'){
      closeLoading();
      switch(value){
        // 搭伙详情
        case 'partner_detail':
          showLoading();
          $.when(
            customSubscribe('postInfo', Session.get("partnerId"))
          ).done(function(){
            closeLoading();
          }).fail(function(){
            closeLoading();
          });
          break;
        // 个人主页
        case 'home_info':
          showLoading();
          $.when(
            customSubscribe('userHomepage_userInfo',Session.get('userId')),
            customSubscribe('userHomepage_posts',Session.get('userId')),
            customSubscribe('userHomepage_photos',Session.get('userId'))
          ).done(function(){
            closeLoading();
          }).fail(function(){
            closeLoading();
          });
          break;
        // 消息
        case 'my_message':
          /*var show = false;
          if(ChatUsers.find({userId:Meteor.userId()}).count() <= 0)
            show = true;

          if(show){showLoading();}
          $.when(
            customSubscribe('chatUsers')
          ).done(function(){
            if(show){closeLoading();}
          }).fail(function(){
            if(show){closeLoading();}
          });*/
          break;
        // 消息列表
        case 'chat_home':
          var show = false;
          if(Template.chat_home_list.__helpers.get('chats')().length <= 0)
            show = true;

          if(show){showLoading();}
          Session.set('chat_home_limit', 18);
          Session.set('chat_home_loading', true);
          $.when(
            customSubscribe('userChats', Session.get("chat_to_userId"), 18, Session.get('chat_home_business'), function(type, err){
                if (type === 'ready') {
                    console.log("chat_home_loading ready.");
                    Session.set('chat_home_loading', false);
                } else if (type === 'stop') {
                    console.log("chat_home_loading stop.");
                    Session.set('chat_home_loading', false);
                } else if (type === 'err') {
                    console.log("chat_home_loading err!! err = "+err);
                    Session.set('chat_home_loading', false);
                }
            })
          ).done(function(){
            //Meteor.setTimeout(function(){document.body.scrollTop = document.body.scrollHeight;}, 500);
            if(show){closeLoading();}
          }).fail(function(){
            //Meteor.setTimeout(function(){document.body.scrollTop = document.body.scrollHeight;}, 500);
            if(show){closeLoading();}
          });
          break;
        // 发现
        //case 'wifiIndex':
          //customSubscribe('login_user_wifi');
          //break;
        // wifi商家列表
//        case 'wifiOffline':
//          showLoading();
//          var geolocation = Session.get('location');
//          var lnglat = geolocation?[geolocation.longitude, geolocation.latitude]:null;
//          Session.set('wifi_off_line_limit', 5);
//
//          $.when(
//            customSubscribe('guest_user_wifi', lnglat, Session.get('wifi_off_line_limit'))
//          ).done(function(){
//            closeLoading();
//          }).fail(function(){
//            closeLoading();
//          });
//          break;
        // 非商家的wifi
        /*case 'wifiUserWifi':
          showLoading();
          $.when(
            customSubscribe('login_user_lan')
          ).done(function(){
            closeLoading();
          }).fail(function(){
            closeLoading();
          });
          break;*/
        // wifi商家详情
        case 'wifiOnline':
          showLoading();
          $.when(
            customSubscribe('wifi_detail_ad', Session.get('wifiOnlineId'))
          ).done(function(){
            Meteor.setTimeout(function(){
              Template.wifiOnline.__helpers.get('updatePagination')();
            }, 500);
            closeLoading();
          }).fail(function(){
            closeLoading();
          });
          break;
        // 文章详情
        case 'notes_detail':
          showLoading();
          $.when(
            customSubscribe('postInfo', Session.get("blackboard_post_id"))
          ).done(function(){
            closeLoading();
          }).fail(function(){
            closeLoading();
          });
          break;
        // 我的搭伙
        case 'my_service':
          showLoading();
          $.when(
            customSubscribe('userHomepage_posts', Meteor.userId())
          ).done(function(){
            closeLoading();
          }).fail(function(){
            closeLoading();
          });
          break;
        // 我->个人资料
        case 'my_detailed':
          showLoading();
          $.when(
            customSubscribe('userHomepage_userInfo', Meteor.userId())
          ).done(function(){
            closeLoading();
          }).fail(function(){
            closeLoading();
          });
          break;
        // 发搭伙
        case 'add_partner':
          if(Tags.find().count() <= 0){
            showLoading();
          }
          $.when(
            customSubscribe('tags')
          ).done(function(){
            closeLoading();
          }).fail(function(){
            closeLoading();
          });
          break;
        // 我
        case 'my_info':
          if(Meteor.userId() != null){
            Meteor.subscribe('userHomepage_userInfo', Meteor.userId());
            Meteor.subscribe('wifiMyBlackboards', Meteor.userId(), Session.get('my_blackboard_limit') || 10);
          }
          break;
        case 'wifiUserWifi':
        case 'wifiIndex':
        case 'wifiPubWifi':
          break;
          /*
          if(WifiPosts.find().count() <= 0){
            showLoading();
          }

          $.when(
            console.log("Frank: wifiUserWifi load data, wifiOnlineId="+Session.get('wifiOnlineId')),
            Session.set('wifis_limit', 5),
            customSubscribe('wifiLists', null, Session.get('wifis_limit')),
            Session.set('wifiHistory_limit', 10),
            Session.set('wifiFavorite_limit', 10),
            //customSubscribe('wifiHistory', Meteor.userId(), null, Session.get('wifiHistory_limit')),
            customSubscribe('wifiFavorite', Meteor.userId(), null, Session.get('wifiFavorite_limit')),
            customSubscribe('wifiUsers', Session.get('wifiOnlineId')),
            customSubscribe('wifiPosts', Session.get('wifiOnlineId'), function(type, reason) {
              //if (type === 'ready') {
                //Template.wifiPubWifiIndex.__helpers.get('updatePagination')();
              //}
            })
          ).done(function(){
            //Meteor.setTimeout(function(){
            //  Template.wifiPubWifiIndex.__helpers.get('updatePagination')();
            //}, 500);
            closeLoading();
          }).fail(function(){
            closeLoading();
          });
          break;
          */
      }
    }
  }

  // 重写 Session.set 方法
  Package['reactive-dict'].ReactiveDict.prototype.set = function(key, value){
    //console.log('Session.set:'+key+','+value);
    if(key === 'view'){
      if (Session.equals('disable_set_scrollTop', true)) {
        window.page.restoreScrollTop('view', value);
      } else {
        window.page.saveScrollTop('view', value);
      }
    } else if(key === 'wifiPubWifi-view'){
      window.page.jumpTabPageAndSaveScrollTop(key, value);
    } else if(key === 'connectedWiFiInfoSubscribe' && value === true){
      var wifiInfo = Session.get('connectedWiFiInfo');
      if(Meteor.users.find({'business.wifi.BSSID': wifiInfo.BSSID, 'profile.isBusiness': 1}).count() <= 0
        && Wifis.find({'BSSID': wifiInfo.BSSID}).count() <= 0){
        amplify.store('wifi_guide_', true);
        if(!amplify.store('wifi_guide_' + wifiInfo.BSSID) && window.localStorage.getItem("firstLog") == 'second'){
          amplify.store('wifi_guide_' + wifiInfo.BSSID, true);
          Blaze.renderWithData(Template.wifiGuide, {wifi_name: wifiInfo.SSID.replace("\"", "").replace("\'", "")}, document.getElementsByTagName('body')[0]);
        }
      }
    }
    sessionSet.call(this, key, value);
    loadData(key, value);
  }

  loadData('view', Session.get('view'));

  Tracker.autorun(function(){
    if(Meteor.userId() != null && !Meteor.loggingIn()){
      Meteor.subscribe('wifiFavorite', Meteor.userId(), null, null);
    }
  });

  /*
  Tracker.autorun(function(){
    if(Meteor.userId() != null && !Meteor.loggingIn()){
      //console.log('user login ' + Meteor.userId());
      Meteor.subscribe('userHomepage_userInfo', Meteor.userId());
      Meteor.subscribe('login_user_wifi');
      Meteor.subscribe('wifiFavorite', Meteor.userId(), null, null);
      Meteor.setTimeout(function(){
        customSubscribe('chatUsers');
        customSubscribe('pushToken');
      }, 4000);
    }
  });
  */
});
