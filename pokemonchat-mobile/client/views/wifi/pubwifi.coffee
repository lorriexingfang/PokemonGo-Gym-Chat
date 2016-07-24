$(window).scroll ->
  scrollTop = $(this).scrollTop()
  scrollHeight = $(document).height()
  windowHeight = $(this).height()

  if Session.equals('wifiPubWifiIndex-view', 'wifiPubWifiIndexUser') and Session.get('wifi_indexuser_all_loaded') isnt true and scrollTop > 0 and scrollTop >= scrollHeight-windowHeight
    limit = Session.get('wifi_indexuser_limit') + 10
    Session.set('wifi_indexuser_limit', limit)

  if Session.equals('wifiPubWifiIndex-view', 'wifiPubWifiIndexWall') and Session.get('wifi_indexwall_all_loaded') isnt true and scrollTop > 0 and scrollTop >= scrollHeight-windowHeight
    limit = Session.get('wifi_indexwall_limit') + 10
    Session.set('wifi_indexwall_loading', true)
    customSubscribe('wifiPostsLimit', Session.get('wifiOnlineId'), limit, (type, reason) ->
      if type == 'ready'
        Session.set('subscribe_indexwall_ready', true)
      Session.set('wifi_indexwall_loading', false)
    )
    Session.set('wifi_indexwall_limit', limit)
    #$('.wifi_indexwall-loading').html('加载中，请稍候...')

  if Session.equals('wifiPubWifiIndex-view', 'wifiPubWifiScores') and Session.get('wifi_scores_loading') isnt true and scrollTop > 0 and scrollTop >= scrollHeight-windowHeight
    limit = Session.get('wifi_scores_limit') + 10
    Session.set('wifi_scores_loading', true)
    customSubscribe 'wifiScoreByWifiId', Session.get('wifiOnlineId'), limit, (type, reason) ->
      if type == 'ready'
        Session.set('subscribe_wifiScore_ready', true)
      Session.set('wifi_scores_loading', false)
    Session.set('wifi_scores_limit', limit)
    #$('.wifi_scores-loading').html('加载中，请稍候...')

Session.setDefault('wifi_indexwall_all_loaded', false)
Session.setDefault('wifi_indexuser_all_loaded', false);
Session.setDefault('wifiPubWifi-view', 'wifiPubWifiIndex')
mySwiper = null
Template.wifiPubWifiIndex.onRendered ()->
  Meteor.setTimeout(
    ()->
      if Meteor.userId()
        Meteor.call 'existWifiUserByWifi', Session.get('wifiOnlineId'), (err, res)->
          if(err or res)
            return
          WifiUsers.insert {
            userId: Meteor.userId(),
            userName: if Meteor.user().profile.nike then Meteor.user().profile.nike else Meteor.user().username,
            userPicture: if Meteor.user().profile.picture then Meteor.user().profile.picture else '/userPicture.png',
            createTime: new Date(),
            wifiID: Session.get('wifiOnlineId'),
            visitTimes: 1,
            userType: 'byview',
          }
    0
  )
  #Session.set('wifiPubWifi-view', 'wifiPubWifiIndex')
  $('#head_input').focus()
  document.body.scrollTop = 0
  Session.set('subscribeFlag',false)
  customSubscribe('wifiUsers', Session.get('wifiOnlineId'))
  if(Session.equals("display-lang",undefined))
    Session.set('display-lang',getUserLanguage())


Template.wifiPubWifi.helpers
  menu_data: ()->
    return {}
  isExistAp: ()->
    if(!Meteor.isCordova)
      return false
    else if(Session.get('connectedWiFiInfo') is '' or Session.get('connectedWiFiInfo') is undefined or Session.get('connectedWiFiInfo') is null)
      return false
    if(Wifis.findOne({'BSSID': Session.get('connectedWiFiInfo').BSSID}) is undefined)
      return false
    else
      return true
  isUseWifiButNoExistAp: () ->
    ###
    if(!Meteor.isCordova)
        return false;
    else if (navigator.connection.type is Connection.WIFI)
        if(Session.get('connectedWiFiInfo') is '' or Session.get('connectedWiFiInfo') is undefined)
            return true
        else if(Wifis.findOne({'BSSID': Session.get('connectedWiFiInfo').BSSID}) is undefined)
            return true
        else
            return false
    else
        return false
    ###
    #console.log("2, wifiPubWifi-curAPStatus="+Session.get('wifiPubWifi-curAPStatus'))
    if (Session.equals('wifiPubWifi-curAPStatus', 'unregistered'))
        return true
    else
        return false
  isFavorite: ()->
    return WifiFavorite.findOne({userId: Meteor.userId(), wifiID: Session.get('wifiOnlineId')}) isnt undefined
  open: (id, tuya)->
    history = Session.get('wifi-pub-wifi-history') || []
    history.push(
      {
        view: Session.get('view')
        id: if Session.equals('view', 'wifiPubWifi') then Session.get('wifiOnlineId') else null
        tab_view: if Session.equals('view', 'wifiPubWifi') then Session.get('wifiPubWifi-view') else null
      }
    )
    Session.set('wifi-pub-wifi-history', history)

    if(id isnt undefined and id isnt null and id isnt '')
      Session.set('wifiPubWifi-view', 'wifiPubWifiIndex')
      Session.set('wifiOnlineId', id)
    if(tuya is true)
      Session.set('view', 'wifiPubwifiReply')
    else
      Session.set('view', 'wifiPubWifi')
  isBack: ()->
    history = Session.get('wifi-pub-wifi-history') || []
    return history.length > 0
  isShowLeft: ()->
    Session.equals('wifiPubWifi-view', 'wifiPubWifiIndex') and Session.get('wifiOnlineId')
  goBack: ()->
    history = Session.get('wifi-pub-wifi-history') || []
    if(history.length > 0)
      view = history.pop()
      Session.set('wifi-pub-wifi-history', history)
      if(view.id isnt '' and view.id isnt null and view.id isnt undefined)
        Session.set('wifiOnlineId', view.id)
      if(view.tab_view isnt '' and view.tab_view isnt null and view.tab_view isnt undefined)
        Session.set('wifiPubWifi-view', view.tab_view)
      Session.set('view', view.view)
  template: ()->
    if(Template.wifiPubWifi.__helpers.get('isBack')())
      'wifiPubWifiIndex'
    else
      Session.get('wifiPubWifi-view')
  isChannel: (val)->
    Meteor.setTimeout(
      ()->
        #console.log "set 'document.body.scrollTop' is " + Session.get("document_body_scrollTop")
        document.body.scrollTop = Session.get("document_body_scrollTop")
      300
    )
    Session.equals('wifiPubWifi-view', val)
  is_android: ()->
    return if Meteor.isCordova then device.platform is 'Android' else false
  is_showShare: ()->
    if(Template.wifiPubWifi.__helpers.get('isBack')())
      return true
    else if (Template.wifiPubWifi.__helpers.get('template')() is 'wifiPubWifiIndex' and Template.wifiPubWifiIndex.__helpers.get('template')() is 'wifiPubWifiIndex_AP')
      return true
    else
      return false
  isLogin: () ->
    if (Meteor.userId())
      return true;
    else
      return false;
  isEnglish: () ->
    if Session.equals("display-lang",undefined)
      getUserLanguage() is 'en'
    else
      Session.equals("display-lang",'en')

  useWiFi: () ->
    if(!Meteor.isCordova)
        return false;
    else if (navigator.connection.type is Connection.WIFI)
        return true
    else
        return false

Template.wifiPubWifi.events
  'click .leftButton': (e)->
    e.stopPropagation()
    window.page.back();

  'click .left-img-btn': (e)->
    e.stopPropagation()
    if Meteor.userId() is null
      PUB.toast('登录了才能操作，赶紧去吧！')
      Session.set('view', 'login')
      return

    Session.set('dialogView', 'scoresSubmitTips')
    Session.set('isDialogView', true)
  'click #socialShare li#add-favorite': (e)->
    $('.head .masker').hide()
    $('.head .right-menu').slideUp()

    if (Meteor.userId())
      wifis = Wifis.findOne({'_id': Session.get('wifiOnlineId')})
      wifiUser = {}

      `for (var key in wifis){if(key == '_id'){wifiUser.wifiID = wifis._id;}else{wifiUser[key] = wifis[key];}}`
      wifiUser.userId = Meteor.userId()
      wifiUser.accessAt = new Date()
      WifiFavorite.insert wifiUser, (err)->
        if(err)
          window.PUB.toast '收藏失败！'
        else
          window.PUB.toast '收藏成功！'
          wifiName = if wifis then wifis.nike else 'NO WIFI NAME'
          trackEvent("收藏小店", "Favorite the store: "+wifiName+", id is "+Session.get('wifiOnlineId'))
    else
      window.PUB.toast '请登录后操作！'
  'click #socialShare li#remove': (e)->
    $('.head .masker').hide()
    $('.head .right-menu').slideUp()
    e.stopPropagation()
    if Meteor.userId() is null
      PUB.toast('登录后才能删除它哦！')
      return

    console.log("");
    wifiInfo = Session.get('connectedWiFiInfo')
    bssid = if wifiInfo then wifiInfo.BSSID else ''
    wifi = Wifis.findOne({'BSSID': bssid});
    id = Session.get('wifiOnlineId');
    if wifi
      if wifi._id isnt id
        PUB.toast('你不能删除你未连接的小店')
        return
    else
      PUB.toast('你不能删除你未连接的小店')
      return

    if wifi.createdBy
       if wifi.createdBy isnt Meteor.userId()
         PUB.toast('只有创建者才能删除小店公告哦！')
         return
    else
       PUB.toast('只有创建者才能删除小店公告哦！')
       return

    if id?
      PUB.confirm(
        "确定要删除此小店吗？"
        ()->
          Wifis.remove({'_id':id})
          Session.set('wifi-user-wifi-view', 'wifiUserWifiLocal')
          Session.set('view', 'wifiPubWifiIndex_NoAP')
      )
  'click #socialShare li#edit-pass': ()->
    $('.head .masker').hide()
    $('.head .right-menu').slideUp()
    Session.set('myWifiPubwifiPasswd', Template.wifiPubWifiIndex_AP.__helpers.get('wifi')().passwd)
    if Meteor.userId() is null
      PUB.toast('请登录后操作！')
      return
    Session.set('view', 'wifiPubwifiPasswd')
  'click #socialShare li#edit-addr': ()->
    $('.head .masker').hide()
    $('.head .right-menu').slideUp()
    Session.set('myWifiPubwifiAddress', Template.wifiPubWifiIndex_AP.__helpers.get('wifi')().location.address)
    if Meteor.userId() is null
      PUB.toast('请登录后操作！')
      return

    if Meteor.userId() isnt Template.wifiPubWifiIndex_AP.__helpers.get('wifi')().createdBy
      PUB.toast('只有小店创建者可以修改！')
      return

    Session.set('view', 'wifiPubwifiAddress')
  'click #socialShare li#jibao': (e)->
    $('.head .masker').hide()
    $('.head .right-menu').slideUp()
    Session.set('reportPostId', '')
    PUB.page("report")
  'click #socialShare li#cancel-favorite': (e)->
    $('.head .masker').hide()
    $('.head .right-menu').slideUp()

    if (Meteor.userId())
      favorite = WifiFavorite.findOne({userId: Meteor.userId(), wifiID: Session.get('wifiOnlineId')});
      if(favorite is undefined)
        window.PUB.toast('您还没有收藏此小店公告！')
      else
        WifiFavorite.remove favorite._id, (err)->
          if(err)
            window.PUB.toast('操作失败，请重试！')
          else
            window.PUB.toast('操作成功！')
            wifiName = if favorite then favorite.nike else 'NO WIFI NAME'
            trackEvent("取消收藏小店", "Unfavorite the store: "+wifiName+", id is "+Session.get('wifiOnlineId'))
    else
      window.PUB.toast '请登录后操作！'
  'click #socialShare li.share': (e)->
    obj = WifiPosts.findOne({wifiID:Session.get('wifiOnlineId')}, {sort: {createTime: -1}})
    wifi_info = Wifis.findOne({'_id': Session.get('wifiOnlineId')});

    nike = wifi_info.nike

    imagesUrl = [];
    image_url = "";
    if obj.images isnt undefined and obj.images.length >0
      imagesUrl.push num.url for num in obj.images
    if imagesUrl.length > 0
      image_url = imagesUrl[0]
    else
      image_url = 'http://localhost.com/fZ8PtzM4rmYJKpCaz_1447184412955_cdv_photo_001.jpg'

    window.plugins.toast.showShortCenter("正在准备分享，请稍等...");
    height = $(window).height()
    $('#blur_overlay').css('height',height)
    $('#blur_overlay').css('z-index', 10000)
    closeBlurOverly = ()->
       $('#blur_overlay').css('height','');
       $('#blur_overlay').css('z-index', -1);


    wifi_summary = "无法获取地址信息"
    if nike
      wifi_summary = "来自" + nike + "的小店公告：" + obj.text

    shareCallback = (result)->
        param = {
          "title": "直播：小店公告",
          "summary": wifi_summary,
          "image_url":result,
          #"target_url": "http://192.168.1.5:3030/pubwifi/"+obj.wifiID
          "target_url": "http://share.youzhadahuo.com:443/pubwifi/"+obj.wifiID
        }
        console.log param.target_url
        $('.head .masker').hide()
        $('.head .right-menu').slideUp()
        if e.currentTarget.id is 'shareToWechatFriend'
          if device.platform is 'Android'
            WechatShare.shareToSession(
              param
              (e)->
                window.PUB.toast '分享成功!'
                closeBlurOverly()
              (e)->
                window.PUB.toast '分享失败!你安装微信了吗？'
                closeBlurOverly()
            )
          else
            WechatShare.share({scene:1,message:{title: param.title,description: param.summary,thumbData:param.image_url,url: param.target_url}},
            ()->
              window.PUB.toast '分享成功!'
              closeBlurOverly()
              return
            ()->
              window.PUB.toast '分享失败!你安装微信了吗？'
              closeBlurOverly()
              return
            )
        else if e.currentTarget.id is 'shareToWechatMoment'
          param.title = param.title + '\n' + param.summary;
          if device.platform is 'Android'
            WechatShare.shareToMoment param,
            (e)->
              window.PUB.toast '分享成功!'
              closeBlurOverly()
              return
            (e)->
              window.PUB.toast '分享失败!你安装微信了吗？'
              closeBlurOverly()
              return
          else
            WechatShare.share({scene:2,message:{title: param.title,description: param.summary,thumbData:param.image_url,url: param.target_url}},
            ()->
              window.PUB.toast '分享成功!'
              closeBlurOverly()
              return
            ()->
              window.PUB.toast '分享失败!你安装微信了吗？'
              closeBlurOverly()
              return)
        else if e.currentTarget.id is 'shareToSystem'
          param.title = param.title + '\n' + param.summary;
          #window.plugins.socialsharing.share(param.title, param.summary, param.image_url, param.target_url)

          window.plugins.socialsharing.share param.title, param.summary, param.image_url, param.target_url, ((result) ->
            console.log "successfully share!"
            console.log result

            userId = Meteor.userId()
            user = Meteor.users.findOne {_id: userId}
            userName = user.profile.nike
            console.log "user name is: " + userName

            if result
              console.log "it is shared"
              Wifis.update({'_id': wifi_info._id}, {$set: {sharedBy: userName}})
              closeBlurOverly()
            else
              console.log "it is not shared"
              closeBlurOverly()
            return
          ), (err) ->
            console.log "fail to share!"
            console.log err
            closeBlurOverly()
            return
    e.preventDefault()
    e.stopPropagation()
    downloadFromBCS(image_url, (result)->
      shareCallback(result)
    )
  'click #btn_back': ()->
    clearNewCommentsMessage(Session.get('wifiOnlineId'))
    Session.set('wifiPubWifiIndex-view', 'wifiPubWifiIndexWall')
    window.page.back()
  'click .right-btn': (e)->
    e.stopPropagation()
    $('.head .masker').show()
    $('.head .right-menu').slideDown()
  'click .head .masker': ()->
    $('.head .masker').hide()
    $('.head .right-menu').slideUp()
  'click #one li': (e)->
    if e.currentTarget.id is 'wifiUserWifiHistory'
      Session.set('wifiHistory_limit', 10)
    if e.currentTarget.id is 'wifiPubWifiIndex'
      wifi = getDeviceWiFiInfo();
      if wifi?
        Session.set('wifiOnlineId', wifi._id);
        clearSysMessageBadge(wifi._id);
    Session.set('wifiPubWifi-view', e.currentTarget.id)
    if Session.get('wifiOnlineId')?
      #customSubscribe('wifiPosts', Session.get('wifiOnlineId'))
      Session.set('wifi_indexwall_limit', 10)
      Session.set('wifi_indexwall_loading', true)
      customSubscribe('wifiPostsLimit', Session.get('wifiOnlineId'), 10, (type, reason) ->
        if type == 'ready'
          Session.set('subscribe_indexwall_ready', true)
        Session.set('wifi_indexwall_loading', false)
      )
  'click #wifiTips': ()->
    if (Meteor.userId() is null)
        PUB.toast('请登录后操作！')
        return
    Session.set("public_upload_index_images", [])
    Session.set('view', 'wifiAddWifi')
  'click #change-lang': ()->
    if Session.equals('display-lang','en')
      Session.set('display-lang','zh')
      Cookies.set('display-lang','zh',360)
      TAPi18n.setLanguage("zh")
    else
      Session.set('display-lang','en') 
      Cookies.set('display-lang','zh',360)
      TAPi18n.setLanguage("en")
    $('.head .masker').hide()
    $('.head .right-menu').slideUp()

Template.wifiPubWifiIndex.helpers
  template: ()->
    if(Template.wifiPubWifi.__helpers.get('isBack')())
      return 'wifiPubWifiIndex_AP'
    else if(Template.wifiPubWifi.__helpers.get('isExistAp')())
      if(!Template.wifiPubWifi.__helpers.get('isBack')())
        Session.set('wifiOnlineId', Wifis.findOne({'BSSID': Session.get('connectedWiFiInfo').BSSID})._id)
      return 'wifiPubWifiIndex_AP'
    else
      return 'wifiPubWifiIndex_NoAP'
  isConnectionWifi: ()->
    return Session.get('connNetworkStatus') is 'online-wifi' and Session.get('connectedWiFiInfo') isnt '' and Session.get('connectedWiFiInfo') isnt undefined and Session.equals('connectedWiFiInfoSubscribe', true)
Session.setDefault('wifiPubWifiIndex-view', 'wifiPubWifiIndexWall')
Session.setDefault('wifiPubWifi-curAPStatus', undefined)
Template.wifiPubWifiIndex_NoAP.helpers
  useWiFi: ()->
    if checkIfUseWiFi()
      return true
    else
      return false
    ###
    if(!Meteor.isCordova)
      return false
    else if(Session.get('connNetworkStatus') is 'online-wifi' and Session.get('connectedWiFiInfo') isnt '' and Session.get('connectedWiFiInfo') isnt undefined)
      if Session.get('wifiPubWifi-curAPStatus') is 'unregistered'
        return true
      else if Session.get('wifiPubWifi-curAPStatus') is 'registered'
        return false
      else
        wifi = Session.get('connectedWiFiInfo')
        console.log '##RDBG wifi: ' + JSON.stringify(wifi)
        Meteor.call "isBSSIDRegisteredOnBusinessOrGraffiti", wifi.BSSID, (error, result) ->
            if error
                DEBUG && console.log 'remote call isBSSIDRegisteredOnBusinessOrGraffiti failed'
            else if result.result is true
                DEBUG && console.log '##RDBG wifi: wifiPubWifi-curAPStatus regitstered'
                Session.set('wifiPubWifi-curAPStatus', 'registered')
            else
                DEBUG && console.log '##RDBG wifi: wifiPubWifi-curAPStatus unregistered'
                Session.set('wifiPubWifi-curAPStatus', 'unregistered')
        return false
    else
      return false
    ###
  getWiFiStatus: ()->
    status = Session.get('wifiPubWifi-curAPStatus')
    console.log('1, getWiFiStatus..., status='+status);
    if status is undefined
      #$('.wifiOnline .main').css('padding-bottom', 0)
      return false
    else if status is 'unregistered'
      #$('.wifiOnline .main').css('padding-bottom', 0)
      return true
    else
      #$('.wifiOnline .main').css('padding-bottom', 64)
      return true
  wifiName: ()->
    return Session.get('connectedWiFiInfo').SSID
Template.wifiPubWifiIndex_NoAP.events
  'click #addHotspot': ()->
    if (Meteor.userId() is null)
      PUB.toast('注册登录后才能创建哦，赶快注册吧！')
      Session.set('view', 'login')
      return

    Session.set("public_upload_index_images", [])
    Session.set('view', 'wifiAddWifi')
Template.wifiPubWifiIndex_AP.onRendered ()->
  popup('wifiHotspotHint')
  popup('wifiPubWifiHint')
  popup('shareToFB')

  customSubscribe('wifiUsers', Session.get('wifiOnlineId'))
  #customSubscribe 'wifiPosts', Session.get('wifiOnlineId'), (type, reason) ->
  #  if type == 'ready'
  #    Session.set('subscribeFlag', true)
  Session.set('wifi_indexwall_limit', 10)
  Session.set('wifi_indexwall_loading', true)
  customSubscribe('wifiPostsLimit', Session.get('wifiOnlineId'), 10, (type, reason) ->
    if type == 'ready'
      Session.set('subscribe_indexwall_ready', true)
      Session.set('subscribeFlag', true)
    Session.set('wifi_indexwall_loading', false)
  )
  if Template.wifiPubWifiIndex_AP.__helpers.get('permissionForWifiScores')()
    Session.set('wifi_scores_loading', true)
    Session.set('wifi_scores_limit', 10)
    customSubscribe 'wifiScoreByWifiId', Session.get('wifiOnlineId'), Session.get('wifi_scores_limit'), (type, reason) ->
      if type == 'ready'
        Session.set('subscribe_wifiScore_ready', true)
        Session.set('wifiScore_subscribeFlag', true)
      Session.set('wifi_scores_loading', false)
  mySwiper = new Swiper(
    '.swiper-container'
    {
      pagination: '.swiper-pagination'
      paginationClickable: true
      autoplayDisableOnInteraction : false
      autoplay: 2000
      watchSlidesProgress: true,
      watchVisibility: true,
      preloadImages: false
      lazyLoading: true
      lazyLoadingInPrevNext: true
      lazyLoadingOnTransitionStart: false
    }
  )
  if device.platform is "Android"
    $('#wrap2 .swiper-container').css 'height',($(window).height()+1)+'px'

  #Session.set('wifiPubWifiIndex-view', 'wifiPubWifiIndexNew')
  hammertime = new Hammer(document.getElementById('wifi-name-title'))
  $remove = this.$('#wifi-name-btn-remove')
  timer = null

  move_left = (ev)->
    if($remove.css('right') is '0px')
      return
    if(ev.deltaX >= -162)
      $remove.css('right', '-'+((ev.deltaX)+162) + 'px')
      clearTimeout(timer)
      if((ev.deltaX)+162 > 0)
        timer = setTimeout(
          ()->
            $remove.animate(
              {
                right: '0px'
              }
              200
            )
          200
        )
  move_right = (ev)->
    if($remove.css('right') is '-162px')
      return
    if(ev.deltaX <= 162)
      $remove.css('right', '-'+(ev.deltaX) + 'px')
      clearTimeout(timer)
      if(ev.deltaX < 162)
        timer = setTimeout(
          ()->
            $remove.animate(
              {
                right: '-162px'
              }
              200
            )
          200
        )
  hammertime.on 'panleft', (ev)->
    move_left(ev)
  hammertime.on 'panright', (ev)->
    move_right(ev)
  hammertime.on 'swipeleft', (ev)->
    move_left(ev)
  hammertime.on 'swipeup', (ev)->
    move_right(ev)
  wifi_id = Session.get('wifiOnlineId')
  wifi = Wifis.findOne({'_id': wifi_id})
  wifiName = if wifi then wifi.nike else 'NO WIFI NAME'
  trackEvent("当前小店", "Access current wifi board : "+wifiName+", id is "+Session.get('wifiOnlineId'))
Template.wifiPubWifiIndex_AP.helpers
  getWidth: ()->
    if Template.wifiPubWifiIndex_AP.__helpers.get('permissionForWifiScores')()
      #$('.wifiOnline .userwifi-tags.tag-3 li').width('25%')
      return '33.3%'
    else
      #$('.wifiOnline .userwifi-tags.tag-3 li').width('33.3%')
      return '50%'
  permissionForWifiScores: ()->
    wifi_id = Session.get('wifiOnlineId')
    wifi = Wifis.findOne({'_id': wifi_id})
    console.log('Frank: Meteor.userId() = '+Meteor.userId())
    if wifi
      if wifi.createdBy
        if wifi.createdBy is Meteor.userId()
          return true
    #if Meteor.userId() is 'N7AnFGfDmPjMMot9G' or Meteor.userId() is 'LnLYiTgfQ4o9WAC9w' or Meteor.userId() is 'hJPmXfbd4F23uPtBX' or Meteor.userId() is 'eFfEcFoZLEQ68k8A6'
    if Meteor.userId() is 'N7AnFGfDmPjMMot9G'
      return true
    return false
  gec: (obj)->
    if obj? and obj.address? and obj.address isnt ''
      return obj.address.replace('"', '').replace('"', '')
    else
      if obj? and obj.coordinates? and obj.coordinates[0] isnt 0 and obj.coordinates[1] isnt 0
        geoc = new BMap.Geocoder();
        point = new BMap.Point(obj.coordinates[0],obj.coordinates[1]);
        geoc.getLocation(point, (rs)->
          if rs and rs.addressComponents
            addComp = rs.addressComponents;
            if addComp.city and addComp.city isnt ''
              console.log(addComp.province + ", " + addComp.city + ", " + addComp.district + ", " + addComp.street + ", " + addComp.streetNumber);
              Session.set("wifiBoardLocation", addComp.province + addComp.city + addComp.district + addComp.street);
              obj.address = Session.get("wifiBoardLocation")
              Wifis.update(
                  {_id: Session.get('wifiOnlineId')}
                  {$set: {'location': obj}}
                  (err, number)->
                    if (err)
                      console.log('update location ' + err);
              )
            else
              requestUrl = "http://maps.googleapis.com/maps/api/geocode/json?latlng="+obj.coordinates[1]+','+obj.coordinates[0]+'&sensor=false'
              Meteor.http.call "GET",requestUrl,(error,result)->
                if result.statusCode is 200
                  results = result.data.results
                  if results.length > 1
                    Session.set("wifiBoardLocation",JSON.stringify(results[1].formatted_address))
                    console.log("gooleappis" + JSON.stringify(results[1].formatted_address))
                    obj.address = Session.get("wifiBoardLocation")
                    Wifis.update(
                        {_id: Session.get('wifiOnlineId')}
                        {$set: {'location': obj}}
                        (err, number)->
                          if err
                            console.log('update location ' + err);
                    )
        )
      return '定位中...';

  name: (obj)->
    if obj?
      obj.replace('"', '').replace('"', '')
    else
      #PUB.toast("当前热点已经被删除，请重新创建热点后使用。")
      if Session.get('view') isnt 'my_message'
        Session.set('view', 'wifiPubWifi')   #If access a removed wifi from message, it will be wrong when back from wifi hotspot
  pass: (obj)->
    if obj and obj.length > 0
      return obj
    return '无'
  getTop: ()->
    #if Template.wifiPubWifi.__helpers.get('isBack')() then '48px' else '48px'
    '48px'
  updatePagination:->
    for item in Template.wifiPubWifiIndex_AP.__helpers.get('urls')()
      loadImage item.src, {id: item.id}, (params)->
        $("#"+params.id+"_img").removeClass().html("<img src='#{this.src}' />")
    #if mySwiper? and mySwiper.update?
    #  mySwiper.update()
  wifi: ()->
    item = Wifis.findOne({'_id': Session.get('wifiOnlineId')});
    return item

  template: ()->
    Session.get('wifiPubWifiIndex-view')
  isChannel: (val)->
    Session.equals('wifiPubWifiIndex-view', val)

  urls: ()->
    hotspots = WifiPosts.find({wifiID:Session.get('wifiOnlineId')}, {sort: {createTime: -1}}).fetch()

    urls = []
    result = []

    if hotspots.length > 0
      for i in [0..hotspots.length - 1]
        id = hotspots[i]._id
        imgs = (hotspots[i].images if hotspots[i].images) || []

        if imgs.length > 0
          for j in [0..imgs.length - 1]
            cur_id = id + '_' + j.toString()
            urls.push({id: cur_id,src:imgs[j].url})
      #console.log "final url is: " + JSON.stringify(urls)

    ##remove the default image, if has other images
    for i in [0..urls.length - 1]
        if urls[i] and urls[i].src is 'http://localhost.com/fZ8PtzM4rmYJKpCaz_1447184412955_cdv_photo_001.jpg'
            urls.splice(i, 1)

    if urls.length == 0
      urls.push({id: '1234567890smaple',src:'http://localhost.com/fZ8PtzM4rmYJKpCaz_1447184412955_cdv_photo_001.jpg'})

    if urls.length > 6
      for i in [0..5]
        result.push({id: urls[i].id,src: urls[i].src})
    else
        result = urls

    if $('#1234567890smaple').length > 0
      $('#1234567890smaple img').attr('src', result[0].src)

    Meteor.setTimeout (->
      if mySwiper? and mySwiper.update?
        mySwiper.update()
      ), 350
    result

Template.wifiPubWifiIndex_AP.events
  'click #two li': (e)->
    Session.set('wifiPubWifiIndex-view', e.currentTarget.id)
  'click .more': ()->
    $('#wall-box').slideToggle()
    Meteor.setTimeout (->
      document.body.scrollTop = document.body.scrollTop + $(window).height() - 200
      return
      ), 300

  'click .btn-hjf': (e)->
    e.stopPropagation()
    if Meteor.userId() is null
      PUB.toast('登录了才能操作，赶紧去吧！')
      Session.set('view', 'login')
      return

    Session.set('dialogView', 'scoresSubmitTips')
    Session.set('isDialogView', true)

  'click .btn-wirter': (e)->
    e.stopPropagation()
    if Meteor.userId() is null
      PUB.toast('登录了才能来小店公告哦，赶紧去吧！')
      Session.set('view', 'login')
      return

    Session.set('dialogView', 'wifiPubwifiReply')
    Session.set('isDialogView', true)
   'click .wifi-name .submit-scores': (e)->
    e.stopPropagation()
    if Meteor.userId() is null
      PUB.toast('登录了才能操作，赶紧去吧！')
      Session.set('view', 'login')
      return

    Session.set('dialogView', 'scoresSubmitTips')
    Session.set('isDialogView', true)
  'click .wifi-name .add-shop': (e)->
    e.stopPropagation()
    if Meteor.userId() is null
      PUB.toast('请登录后操作！')
    else if(Meteor.user().profile.isBusiness isnt 1)
      Template.edit_wifi.__helpers.get('add_wifi')(
        ()->
          PUB.toast('您不是商家，请先补充商家资料！')
          PUB.toast('审核后会自动绑定到你的商家下！')
          Session.set('view', 'my_business')
      )
    else
      Template.edit_wifi.__helpers.get('add_wifi')(
        ()->
          PUB.toast('绑定成功！')
      )
  'click .wifi-name .remove': (e)->
    e.stopPropagation()
    if Meteor.userId() is null
      PUB.toast('登录后才能删除它哦！')
      return

    console.log("");
    wifiInfo = Session.get('connectedWiFiInfo')
    bssid = if wifiInfo then wifiInfo.BSSID else ''
    wifi = Wifis.findOne({'BSSID': bssid});
    id = Session.get('wifiOnlineId');
    if wifi
      if wifi._id isnt id
        PUB.toast('你不能删除你未连接的小店')
        return
    else
      PUB.toast('你不能删除你未连接的小店')
      return

    if wifi.createdBy
       if wifi.createdBy isnt Meteor.userId()
         PUB.toast('只有创建者才能删除小店公告哦！')
         return
    else
       PUB.toast('只有创建者才能删除小店公告哦！')
       return

    if id?
      PUB.confirm(
        "确定要删除此小店吗？"
        ()->
          Wifis.remove({'_id':id})
          Session.set('wifi-user-wifi-view', 'wifiUserWifiLocal')
          Session.set('view', 'wifiPubWifiIndex_NoAP')
      )
  'click .wifi-name': ()->
    Session.set('myWifiPubwifiPasswd', $('#wifi-name-title a').html())
    if Meteor.userId() is null
      PUB.toast('请登录后操作！')
      return
    Session.set('view', 'wifiPubwifiPasswd')
  'click .swiper-slide': (e)->
    images = new Array()
    selected = ''
    urls = Template.wifiPubWifiIndex_AP.__helpers.get('urls')()
    for item in urls
      images.push(item.src)
      if(item.id is e.currentTarget.id)
        selected = item.src

    Session.set("images_view_images", images)
    Session.set("images_view_images_selected", selected)
    Session.set("return_view", Session.get("view"))
    Session.set("document.body.scrollTop", document.body.scrollTop)
    #if wifiOnline_blazeload isnt null
    #  Template.wifiOnline.__helpers.get('close')()
    PUB.page("images_view")


Template.wifiPubWifiIndexNew.helpers
  first: ()->
    return Template.wifiPubWifiIndexNew.__helpers.get('posts')()[0]
  posts: ()->
    WifiPosts.find({'wifiID': Session.get('wifiOnlineId')}, {sort: {createTime: -1}}).fetch();

  time: (val)->
    now = new Date()
    GetTime0(now - val)

Template.wifiPubWifiIndexNew.events
  'click .imgs img': (e)->
    e.stopPropagation()
    post = WifiPosts.find({'wifiID': Session.get('wifiOnlineId')}, {sort: {createTime: -1}}).fetch()[0]
    images = new Array();
    post.images.forEach((item)->
        return images.push(item.url);
    );
    Session.set("images_view_images", images);
    Session.set("images_view_images_selected", e.currentTarget.src);
    Session.set("return_view", Session.get("view"));
    Session.set("document.body.scrollTop", document.body.scrollTop);
    PUB.page("images_view");
  'click .images img': (e)->
    e.stopPropagation()
    post = WifiPosts.findOne({
        _id: e.currentTarget.parentNode.parentNode.id
    });
    images = new Array();
    post.images.forEach((item)->
        return images.push(item.url);
    );
    Session.set("images_view_images", images);
    Session.set("images_view_images_selected", e.currentTarget.src);
    Session.set("return_view", Session.get("view"));
    Session.set("document.body.scrollTop", document.body.scrollTop);
    PUB.page("images_view");
  'click li': (e)->
    if(Meteor.userId() is null)
      PUB.toast('登录后才可以聊天哦~')
    else if(Meteor.userId() is @userId)
      PUB.toast('自己不能和自己聊天哦~')
    else
      Session.set('chat_home_business', false)
      Session.set "chat_to_userId", @userId
      Session.set "chat_to_userName", @userName
      Session.set 'chat_return_view', Session.get("view")
      PUB.page "chat_home"


Template.wifiPubWifiIndexWall.onRendered ()->
  #value = ($(window).width()-20-50-2-15)/3
  #$('.con-main .images img').css('width', value)
  #$('.con-main .images img').css('height', value)
  #$('.con-main .images li').css('width', value)
  #$('.con-main .images li').css('height', value)

  #Session.set('wifi_indexwall_all_loaded', false);
  #Session.set('wifi_indexwall_limit', 10);
  #Session.set('wifi_indexuser_all_loaded', false);
  #Session.set('wifi_indexuser_limit', 10);
  #if device.platform is "iOS" or device.platform is "Android"
  $('.pubwifi-comment .comment-mask').bind((if document.ontouchstart isnt null then 'mousedown' else 'touchstart'), (e)->
    if $('.pubwifi-comment').css('display') isnt 'none'
      #console.log("Frank: active id is "+document.activeElement.id)
      $('.pubwifi-comment-form #text').blur()
  )

Session.setDefault('wifi_indexwall_limit', 10)
Session.setDefault('wifi_indexuser_limit', 10)
Template.wifiPubWifiIndexWall.helpers
  isLoading: ()->
    return Session.equals('subscribeFlag', false)
  lastImg: (newcomments)->
    if(newcomments[newcomments.length-1].userPicture)
      return newcomments[newcomments.length-1].userPicture
    else
      return '/userPicture.png'
  length: (newcomments)->
    return newcomments.length
  hasNewComments: (newcomments)->
    if newcomments isnt undefined and newcomments isnt null and newcomments.length > 0
      return true
    else
      return false
  newcomments: ()->
    if Meteor.user() is undefined or Meteor.user() is null
      return []
    newcomments = ChatUsers.findOne({userId: Meteor.user()._id, toUserId: Session.get('wifiOnlineId'), msgTypeEx: 'wifiboard'})
    if newcomments is undefined or newcomments is null
      return []
    #console.log("newcomments="+JSON.stringify(newcomments))
    return newcomments.comments
  posts: ()->
    limit = Session.get('wifi_indexwall_limit')
    if limit is undefined or limit is null
      limit = 10
    posts = WifiPosts.find({'wifiID': Session.get('wifiOnlineId')}, {sort: {createTime: -1}, limit: limit}).fetch()
    if posts.length < limit
        Session.set('wifi_indexwall_all_loaded', true)
    else
        Session.set('wifi_indexwall_all_loaded', false)

    if Session.get('subscribeFlag') is true
      return posts

  time: (val)->
    now = new Date()
    GetTime0(now - val)

  isAdmin: ()->
    wifi_id = Session.get('wifiOnlineId')
    wifi = Wifis.findOne({'_id': wifi_id})
    return wifi.createdBy is Meteor.userId()

  isDelete: (val)->
    userid = Meteor.userId()
    return userid is val
  hasData: (obj)->
    if obj isnt undefined
      return obj.length > 0
    else
      return false

  addCommentbar: (id)->
    if Session.equals('current_comment_id', id)
      #comment = $('.main .main');
      #comment.scrollTop(chatMessages.get(0).scrollHeight+99999);
      Meteor.setTimeout ()->
          #document.body.scrollTop = Session.get('current_comment_scrollTop')
          $('#comment_toolbar .text').focus()
        , 300
      #document.body.scrollTop = Session.set('current_comment_scrollTop'
      true
    else
      false

  has_more_data: () ->
    !Session.get('wifi_indexwall_all_loaded')

Template.wifiPubWifiIndexWall.events
  'click #newcomments .title': ()->
    $('#newcomments .title').hide()
    $('#newcomments ul').show()
  'click .to-comment': (e)->
    e.stopPropagation()
    document.body.scrollTop = $(e.currentTarget).offset().top+90+33
  'click span.comment': (e)->
    e.stopPropagation()
    if(Meteor.userId() is null)
      PUB.toast('请登录后操作！')
    #else if(!testDeviceConnectedWifi() or getDeviceWifiBusiness() is undefined or getDeviceWifiBusiness()._id isnt Session.get('wifiOnlineId'))
    #  PUB.toast('请连接到此商家的WIFI后操作！')
    else if (@userId is undefined)
      return
    else
      ele = $(e.target)
      if($('#'+@_id+' .usercomments').length > 0)
        Template.pubwifi_comment.__helpers.get('show')(@_id, ele.offset().top+90+$('#'+@_id+' .usercomments').height())
      else
        Template.pubwifi_comment.__helpers.get('show')(@_id, ele.offset().top+80)
      $('.pubwifi-comment-form #text').focus()

#      if(!!navigator.userAgent.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/))
#        document.body.scrollTop = 999999
#        $("body").animate({ scrollTop: 999999}, 300);
#        Session.set('pubwifi-comment-scroll-top', document.body.scrollTop)
      #Meteor.setTimeout (->
      #    document.body.scrollTop = 999999
      #    $('.pubwifi-comment-form #text').focus()
      #    $("body").animate({ scrollTop: 999999}, 100);
      #    Session.set('pubwifi-comment-scroll-top', document.body.scrollTop)
      #  ), 200
#
#     Session.set('wifiPubwifiReplyParamMsg', this.userName)
#     #Session.set('view', 'wifiPubwifiReply')
#     #PUB.page 'wifiPubwifiReply'
#     console.log("e.currentTarget.parentNode.parentNode.parentNode.id="+e.currentTarget.parentNode.parentNode.parentNode.id)
#     parentID = e.currentTarget.parentNode.parentNode.parentNode.id
#     Session.set('current_comment_scrollTop', $('#'+parentID+' .comment').scrollTop())
#     console.log("Frank: scrollTop="+$('#'+parentID+' .comment').scrollTop())
#     Session.set('current_comment_id', e.currentTarget.parentNode.parentNode.parentNode.id)


  'click #deleteImage': (e)->
    e.stopPropagation()
    id = $(e.currentTarget).parent().attr("id")

    if id?
      PUB.confirm(
        "确定要删除点评吗？"
        ()->
          WifiPosts.remove({'_id':id})
      )

  'click .report .content .images img': (e)->
    e.stopPropagation()
    #post = WifiPosts.findOne({
    #    _id: e.currentTarget.parentNode.parentNode.id
    #});
    #images = new Array();
    #post.images.forEach((item)->
    #    return images.push(item.url);
    #);
    
    #wifiPhotos = WifiPhotos.find({wifiID:Session.get('wifiOnlineId')}, {sort:{createTime:-1}}).fetch()
    #if wifiPhotos.length <= 0
    #  console.log("pubwifi.coffee: ERROR, can't find any photos!")
    #  return

    curWifi = Wifis.findOne({'_id': Session.get('wifiOnlineId')})
    photosCnt = 0
    if curWifi and curWifi.photosCnt
      photosCnt = curWifi.photosCnt
    console.log("wifiID="+Session.get('wifiOnlineId')+", photosCnt="+photosCnt)

    #Set image array for showing
    images = new Array()
    curWifiPosts = WifiPosts.find({'wifiID': Session.get('wifiOnlineId')}, {sort: {createTime: -1}}).fetch()
    if curWifiPosts.length > 0
      for i in [0..curWifiPosts.length-1]
        if curWifiPosts[i].images and curWifiPosts[i].images.length > 0
          for j in [0..curWifiPosts[i].images.length-1]
            images.push(curWifiPosts[i].images[j].url)
      loadedCreateTime = curWifiPosts[curWifiPosts.length-1].createTime

    #Fill one picture
    loadedPhotosCnt = images.length
    if loadedPhotosCnt < photosCnt
      #for i in [loadedPhotosCnt..photosCnt-1]
      images.push('/fullscreenloading.png') #/lazy-loading-70.gif
    if e.currentTarget.getAttribute("data-original")
      selectedImage = e.currentTarget.getAttribute("data-original")
    else
      selectedImage = e.currentTarget.src
    FullScreenShowWifiPhotos(images, selectedImage, Session.get('wifiOnlineId'), loadedPhotosCnt, photosCnt, loadedCreateTime)
  'click .report li>div.img>img': (e)->
    # this click event is the same with the below event, so please the same!!!!
    # if can merge this two click event, it will be great!!!

    #console.log("className = "+$(e.target).className)
    #if !$(e.target).hasClass('con-main') and !$(e.target).hasClass('title') and !$(e.target).hasClass('text')
    #  console.log('Please click again!');
    #  return
    #console.log('userid: ' + Meteor.userId() + ', user: ' + @userId)
    if(Meteor.userId() is null)
      PUB.toast('请登录后操作！')
    #else if(!testDeviceConnectedWifi() or getDeviceWifiBusiness() is undefined or getDeviceWifiBusiness()._id isnt Session.get('wifiOnlineId'))
    #  PUB.toast('请连接到此商家的WIFI后操作！')
    else if (@userId is undefined)
      return
    else if(Meteor.userId() is @userId)
      PUB.toast('不能和自己聊天哦~')
    else
      Session.set('chat_home_business', false)
      Session.set "chat_to_userId", @userId
      Session.set "chat_to_userName", @userName
      Session.set 'chat_return_view', Session.get("view")
      PUB.page "chat_home"
  'click .report li>.content>.title': (e)->
    # this click event is the same with the above event, so please the same!!!!
    #console.log("className = "+$(e.target).className)
    #if !$(e.target).hasClass('con-main') and !$(e.target).hasClass('title') and !$(e.target).hasClass('text')
    #  console.log('Please click again!');
    #  return
    #console.log('userid: ' + Meteor.userId() + ', user: ' + @userId)
    if(Meteor.userId() is null)
      PUB.toast('请登录后操作！')
    #else if(!testDeviceConnectedWifi() or getDeviceWifiBusiness() is undefined or getDeviceWifiBusiness()._id isnt Session.get('wifiOnlineId'))
    #  PUB.toast('请连接到此商家的WIFI后操作！')
    else if (@userId is undefined)
      return
    else if(Meteor.userId() is @userId)
      PUB.toast('不能和自己聊天哦~')
    else
      Session.set('chat_home_business', false)
      Session.set "chat_to_userId", @userId
      Session.set "chat_to_userName", @userName
      Session.set 'chat_return_view', Session.get("view")
      PUB.page "chat_home"

wifiUserExists = (user, users) ->
  i = 0

  while i < users.length
    return true  if user._id is users[i]._id
    i++
  false
filterDuplicatedWifiUsers = (wifi_users) ->
  retArray = []
  return retArray  if not wifi_users? or wifi_users is `undefined`
  i = 0

  while i < wifi_users.length
    retArray.push wifi_users[i]  unless wifiUserExists(wifi_users[i], retArray)
    i++
  retArray
statusCompareFunc = (a, b) ->
  curA = Meteor.users.find({_id: a.userId})
  curB = Meteor.users.find({_id: b.userId})
  if curA is null or curA is undefined or curB is null or curB is undefined
    return 0
  if curA.status is 'online'
    return 1
  else
    return -1

sortByOnlineStatus = (wifi_users) ->
  orderby = (a, b)->
    if a.status is 'online'
      return -1
    else
      return 1
  wifi_users.sort(orderby)
  wifi_users
sortByOnlineStatus2 = (wifi_users) ->
  sortedWifiUsers = []
  sortedOnlineWifiUsers = []
  sortedOfflineWifiUsers = []
  if wifi_users.length > 0
    for i in [0..wifi_users.length-1]
      if wifi_users[i].status is 'onine'
        sortedOnlineWifiUsers.push(wifi_users[i])
      else
        sortedOfflineWifiUsers.push(wifi_users[i])
  if sortedOnlineWifiUsers.length > 0
    for i in [0..sortedOnlineWifiUsers.length-1]
      sortedWifiUsers.push(sortedOnlineWifiUsers[i])
  if sortedOfflineWifiUsers.length > 0
    for i in [0..sortedOfflineWifiUsers.length-1]
      sortedWifiUsers.push(sortedOfflineWifiUsers[i])
  sortedWifiUsers

Template.wifiPubWifiIndexUserRank.helpers
  ranks: ()->
    tpl = Template.instance()
    ranks = []
    times = tpl.data.data
    if times and times >= 2
      start = times - 1
      while start > 3
        ranks.push(3)
        start = start - 3
      if start
        ranks.push(start)
    ranks
  isEq: (p1, p2)->
    p1 == p2

Template.wifiPubWifiIndexUser.onRendered ()->
  popup('customerBackHint')
Template.wifiPubWifiIndexUser.helpers
  posts: ()->
    limit = Session.get('wifi_indexuser_limit')
    if limit is undefined or limit is null
      limit = 10
    wifi_users = WifiUsers.find({'wifiID': Session.get('wifiOnlineId')}, {sort: {createTime: -1}, limit: limit}).fetch()
    if wifi_users.length < limit
        Session.set('wifi_indexuser_all_loaded', true)
    else
        Session.set('wifi_indexuser_all_loaded', false)
    sortByOnlineStatus2(wifi_users)
    ###
    #customSubscribe('wifiUsers', Session.get('wifiOnlineId'))
    console.log("Frank: wifiOnlineId="+Session.get('wifiOnlineId'))
    wifi_users = WifiUsers.find({'wifiID': Session.get('wifiOnlineId')}, {sort: {createTime: -1}}).fetch()
    filterDuplicatedWifiUsers(wifi_users)
    idArray = []
    i = 0
    while i < wifi_users.length
        idArray.push wifi_users[i].userId
        i++
    customSubscribe('wifiUserOnlineStatus', idArray)
    sortByOnlineStatus(wifi_users)
    ###
  isBypasser: (uType)->
    if uType is 'user'
        false
    else
        true
  time: (val)->
    now = new Date()
    GetTime0(now - val)
  has_more_data: () ->
    !Session.get('wifi_indexuser_all_loaded')
Template.wifiPubWifiIndexUser.events
  'click li': (e)->
    if(Meteor.userId() is null)
      PUB.toast('请登录后操作！')
    #else if(!testDeviceConnectedWifi() or getDeviceWifiBusiness() is undefined or getDeviceWifiBusiness()._id isnt Session.get('wifiOnlineId'))
    #  PUB.toast('请连接到此商家的WIFI后操作！')
    else if(Meteor.userId() is @userId)
      PUB.toast('不能和自己聊天哦~')
    else
      Session.set('chat_home_business', false)
      Session.set "chat_to_userId", @userId
      Session.set "chat_to_userName", @userName
      Session.set 'chat_return_view', Session.get("view")
      PUB.page "chat_home"

Template.wifiPubWifiIndexSuperAP.onRendered ()->
  Meteor.subscribe('superAPOne', Session.get('wifiOnlineId'))
Template.wifiPubWifiIndexSuperAP.helpers
  superAP: ()->
    SuperWifis.find({'wifiID': Session.get('wifiOnlineId')}, {sort: {createTime: -1}}).fetch()
  getWifiInfo: (importWifiID)->
    #customSubscribe('wifiPosts', importWifiID)
    Wifis.findOne({'_id': importWifiID})
  getUserList: (importWifiID)->
    customSubscribe('wifiUsers', importWifiID)
    WifiUsers.find({'wifiID': importWifiID}, {sort: {createTime: -1}}).fetch()
  time: (val)->
    now = new Date()
    GetTime0(now - val)
  get_distance: (val)->
    location = Session.get('location')
    if val isnt undefined and val.location isnt undefined and location isnt undefined
      distance(location.longitude, location.latitude, val.location.coordinates[0], val.location.coordinates[1])
    else
      ''
Template.wifiPubWifiIndexSuperAP.events
  'click .add': (e)->
    if(Meteor.userId() is null)
      PUB.toast('请登录后操作！')
      return

    wifiOnlineId = Session.get('wifiOnlineId')
    wifi = Wifis.findOne({'_id': wifiOnlineId})

    if wifi and wifi.createdBy
      if wifi.createdBy isnt Meteor.userId()
        PUB.toast('只有创建者才能添加超级热点哦！')
        return
    else
      PUB.toast('只有创建者才能添加超级热点哦！')
      return
    Session.set('view', 'wifiPubwifiAddSuperAP')
  'click .wifi-superUser .header .btns': (e)->
    if($(e.currentTarget).find('i.fa-plus').length > 0)
      $(e.currentTarget).html('<i class="fa fa-minus"></i>')
      $(e.currentTarget).parent().parent().find('ul').slideDown()
    else
      $(e.currentTarget).html('<i class="fa fa-plus"></i>')
      $(e.currentTarget).parent().parent().find('ul').slideUp()
  'click .wifi-superUser .header .con-main': (e)->
    customSubscribe('superAPOne', this._id)
    Template.wifiPubWifi.__helpers.get('open')(this._id)
#    Session.set('wifiOnlineId', this._id)
#    Session.set('wifiPubWifi_return', Session.get('view'))
#    Session.set('view', "wifiPubWifi");
  'click .wifi-superUser .wifi-user li': (e)->
    if(Meteor.userId() is null)
      PUB.toast('请登录后操作！')
    else if(Meteor.userId() is @userId)
      PUB.toast('不能和自己聊天！')
    else
      Session.set('chat_home_business', false)
      Session.set "chat_to_userId", @userId
      Session.set "chat_to_userName", @userName
      Session.set 'chat_return_view', Session.get("view")
      PUB.page "chat_home"

Template.wifiPubwifiAddSuperAP.onRendered ()->
  Session.set('superAP_checked_count', 0)
  Session.set('superAP_unchecked_wifis', [])
Template.wifiPubwifiAddSuperAP.helpers
  isAdded: (id)->
    if SuperWifis.find({'wifiID': Session.get('wifiOnlineId'), 'importWifiID': id}).count()>0 then true else false
  wifis: (obj)->
    try
      geolocation = Session.get('location')
      lnglat = if geolocation? then [geolocation.longitude, geolocation.latitude] else [0, 0];
      wifis = Wifis.find({"_id":{"$ne":Session.get('wifiOnlineId')}, "location.coordinates":{$near:lnglat,  $maxDistance: 2000000 }},{sort: {createTime: -1}}).fetch()
    catch
      console.log('请使用“Wifis.ensureIndex({"location.coordinates": "2d"})”为Wifis的location建立索引')
      return []
    wifis
  time: (val)->
    now = new Date()
    GetTime0(now - val)
  noUsers: (obj)->
    if obj isnt undefined
      if obj.length <= 0 then true else false
    else
      true
  get_distance: (val)->
    location = Session.get('location')
    if val isnt undefined and val.location isnt undefined and location isnt undefined
      distance(location.longitude, location.latitude, val.location.coordinates[0], val.location.coordinates[1])
    else
      ''
Template.wifiPubwifiAddSuperAP.events
  'click #btn_back': ()->
    window.page.back()
  'click .right-btn': ()->
    wifis = Template.wifiPubwifiAddSuperAP.__helpers.get('wifis')()
    uncheckedWifis = Session.get('superAP_unchecked_wifis')
    for item in uncheckedWifis
      wifi = SuperWifis.find({'wifiID': Session.get('wifiOnlineId'), 'importWifiID': item})
      if wifi.count() > 0
        for subItem in wifi.fetch()
          SuperWifis.remove('_id': subItem._id)
    for item in wifis
      if $('.wifi-user li#' + item._id+' .chebox i').hasClass('fa-check-square-o')
        if SuperWifis.find({'wifiID': Session.get('wifiOnlineId'), 'importWifiID': item._id}).count() is 0
          wifiItem = item
          wifiItem.importWifiID = item._id
          wifiItem.wifiID = Session.get('wifiOnlineId')
          wifiItem.importAt = new Date()
          wifiItem.userId = Meteor.userId()
          wifiItem._id = (new Mongo.ObjectID)._str
          SuperWifis.insert(wifiItem)
    window.page.back()
  'click .wifi-user li': (e)->
    if($(e.currentTarget).find('.chebox i.fa-square-o').length > 0)
      count = Session.get('superAP_checked_count')+1;
      if count > 3
        PUB.toast('您一次最多只能添加3个到超级热点中。')
        return
      $(e.currentTarget).find('.chebox').html('<i class="fa fa-check-square-o"></i>')
      Session.set('superAP_checked_count', count)
    else
      $(e.currentTarget).find('.chebox').html('<i class="fa fa-square-o"></i>')
      Session.set('superAP_checked_count', Session.get('superAP_checked_count')-1)
      if SuperWifis.find({'wifiID': Session.get('wifiOnlineId'), 'importWifiID': this._id}).count() > 0
        uncheckedWifis = Session.get('superAP_unchecked_wifis')
        isPushed = 0
        for item in uncheckedWifis
          if item is this._id
            isPushed = 1
            break
        if isPushed is 0
          uncheckedWifis.push(this._id)
          Session.set('superAP_unchecked_wifis', uncheckedWifis)


# wifiPubWifiScores  积分
Template.wifiPubWifiScores.onRendered ()->
  value = ($(window).width()-20-50-2-15)/3
  $('.con-main .images img').css('width', value)
  $('.con-main .images img').css('height', value)
  $('.con-main .images li').css('width', value)
  $('.con-main .images li').css('height', value)
  #Session.set('wifi_indexwall_all_loaded', false);
  #Session.set('wifi_indexwall_limit', 10);
  #if device.platform is "iOS" or device.platform is "Android"
  $('.pubwifi-comment .comment-mask').bind((if document.ontouchstart isnt null then 'mousedown' else 'touchstart'), (e)->
    if $('.pubwifi-comment').css('display') isnt 'none'
      #console.log("Frank: active id is "+document.activeElement.id)
      $('.pubwifi-comment-form #text').blur()
  )

Template.wifiPubWifiScores.helpers
  whichType: (type)->
    if type is 'consume'
      return '消费兑换'
    else
      return '其它兑换'
  isLoading: ()->
    return Session.equals('wifiScore_subscribeFlag', false)
  lastImg: (newcomments)->
    if(newcomments[newcomments.length-1].userPicture)
      return newcomments[newcomments.length-1].userPicture
    else
      return '/userPicture.png'
  length: (newcomments)->
    return newcomments.length
  hasNewComments: (newcomments)->
    if newcomments isnt undefined and newcomments isnt null and newcomments.length > 0
      return true
    else
      return false
  newcomments: ()->
    if Meteor.user() is undefined or Meteor.user() is null
      return []
    newcomments = ChatUsers.findOne({userId: Meteor.user()._id, toUserId: Session.get('wifiOnlineId'), msgTypeEx: 'wifiboard'})
    if newcomments is undefined or newcomments is null
      return []
    #console.log("newcomments="+JSON.stringify(newcomments))
    return newcomments.comments
  posts: ()->
    limit = Session.get('wifi_scores_limit')
    if limit is undefined or limit is null
      limit = 10
    posts = Scores.find({'wifiId': Session.get('wifiOnlineId')}, {sort: {createdAt: -1}, limit: limit}).fetch()
    if posts.length < limit
        Session.set('wifi_scores_all_loaded', true)
    else
        Session.set('wifi_scores_all_loaded', false)

    if Session.get('subscribeFlag') is true
      return posts

  time: (val)->
    now = new Date()
    GetTime0(now - val)

  isAdmin: ()->
    wifi_id = Session.get('wifiOnlineId')
    wifi = Wifis.findOne({'_id': wifi_id})
    return wifi.createdBy is Meteor.userId()

  isDelete: (val)->
    userid = Meteor.userId()
    return userid is val
  hasData: (obj)->
    if obj isnt undefined
      return obj.length > 0
    else
      return false

  addCommentbar: (id)->
    if Session.equals('current_comment_id', id)
      #comment = $('.main .main');
      #comment.scrollTop(chatMessages.get(0).scrollHeight+99999);
      Meteor.setTimeout ()->
          #document.body.scrollTop = Session.get('current_comment_scrollTop')
          $('#comment_toolbar .text').focus()
        , 300
      #document.body.scrollTop = Session.set('current_comment_scrollTop'
      true
    else
      false

  loadingHint: () ->
    if Session.get('wifi_scores_loading')
      return '正在加载中...'
    else if Session.get('wifi_scores_all_loaded')
      return '已显示全部'
    else
      return '上拉加载更多...'

Template.wifiPubWifiScores.events
  'click #newcomments .title': ()->
    $('#newcomments .title').hide()
    $('#newcomments ul').show()
  'click span.comment': (e)->
    e.stopPropagation()
    if(Meteor.userId() is null)
      PUB.toast('请登录后操作！')
    #else if(!testDeviceConnectedWifi() or getDeviceWifiBusiness() is undefined or getDeviceWifiBusiness()._id isnt Session.get('wifiOnlineId'))
    #  PUB.toast('请连接到此商家的WIFI后操作！')
    else if (@userId is undefined)
      return
    else
      ele = $(e.target)
      if($('#'+@_id+' .usercomments').length > 0)
        Template.pubwifi_comment.__helpers.get('show')(@_id, ele.offset().top+90+$('#'+@_id+' .usercomments').height())
      else
        Template.pubwifi_comment.__helpers.get('show')(@_id, ele.offset().top+80)
      $('.pubwifi-comment-form #text').focus()

#      if(!!navigator.userAgent.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/))
#        document.body.scrollTop = 999999
#        $("body").animate({ scrollTop: 999999}, 300);
#        Session.set('pubwifi-comment-scroll-top', document.body.scrollTop)
      #Meteor.setTimeout (->
      #    document.body.scrollTop = 999999
      #    $('.pubwifi-comment-form #text').focus()
      #    $("body").animate({ scrollTop: 999999}, 100);
      #    Session.set('pubwifi-comment-scroll-top', document.body.scrollTop)
      #  ), 200
#
#     Session.set('wifiPubwifiReplyParamMsg', this.userName)
#     #Session.set('view', 'wifiPubwifiReply')
#     #PUB.page 'wifiPubwifiReply'
#     console.log("e.currentTarget.parentNode.parentNode.parentNode.id="+e.currentTarget.parentNode.parentNode.parentNode.id)
#     parentID = e.currentTarget.parentNode.parentNode.parentNode.id
#     Session.set('current_comment_scrollTop', $('#'+parentID+' .comment').scrollTop())
#     console.log("Frank: scrollTop="+$('#'+parentID+' .comment').scrollTop())
#     Session.set('current_comment_id', e.currentTarget.parentNode.parentNode.parentNode.id)


  'click #deleteImage': (e)->
    e.stopPropagation()
    id = $(e.currentTarget).parent().attr("id")

    if id?
      PUB.confirm(
        "确定要删除此积分记录吗？"
        ()->
          Scores.remove({'_id':id})
      )

  'click .report .content .images img': (e)->
    e.stopPropagation()
    post = Scores.findOne({
        _id: e.currentTarget.parentNode.parentNode.id
    });
    images = new Array();
    post.images.forEach((item)->
        return images.push(item.url);
    );
    Session.set("images_view_images", images);
    Session.set("images_view_images_selected", e.currentTarget.src);
    Session.set("return_view", Session.get("view"));
    Session.set("document.body.scrollTop", document.body.scrollTop);
    PUB.page("images_view");
  'click .report li>div.img>img': (e)->
    # this click event is the same with the below event, so please the same!!!!
    # if can merge this two click event, it will be great!!!

    #console.log("className = "+$(e.target).className)
    #if !$(e.target).hasClass('con-main') and !$(e.target).hasClass('title') and !$(e.target).hasClass('text')
    #  console.log('Please click again!');
    #  return
    #console.log('userid: ' + Meteor.userId() + ', user: ' + @userId)
    if(Meteor.userId() is null)
      PUB.toast('请登录后操作！')
    #else if(!testDeviceConnectedWifi() or getDeviceWifiBusiness() is undefined or getDeviceWifiBusiness()._id isnt Session.get('wifiOnlineId'))
    #  PUB.toast('请连接到此商家的WIFI后操作！')
    else if (@userId is undefined)
      return
    else if(Meteor.userId() is @userId)
      PUB.toast('不能和自己聊天哦~')
    else
      Session.set('chat_home_business', false)
      Session.set "chat_to_userId", @userId
      Session.set "chat_to_userName", @userName
      Session.set 'chat_return_view', Session.get("view")
      PUB.page "chat_home"
  'click .report li>.content>.title': (e)->
    # this click event is the same with the above event, so please the same!!!!
    #console.log("className = "+$(e.target).className)
    #if !$(e.target).hasClass('con-main') and !$(e.target).hasClass('title') and !$(e.target).hasClass('text')
    #  console.log('Please click again!');
    #  return
    #console.log('userid: ' + Meteor.userId() + ', user: ' + @userId)
    if(Meteor.userId() is null)
      PUB.toast('请登录后操作！')
    #else if(!testDeviceConnectedWifi() or getDeviceWifiBusiness() is undefined or getDeviceWifiBusiness()._id isnt Session.get('wifiOnlineId'))
    #  PUB.toast('请连接到此商家的WIFI后操作！')
    else if (@userId is undefined)
      return
    else if(Meteor.userId() is @userId)
      PUB.toast('不能和自己聊天哦~')
    else
      Session.set('chat_home_business', false)
      Session.set "chat_to_userId", @userId
      Session.set "chat_to_userName", @userName
      Session.set 'chat_return_view', Session.get("view")
      PUB.page "chat_home"



Template.comment_toolbar.onRendered ()->
  $('#text').on('keyup input', (e)->
    comment = $('#text').val()
    comment = $.trim(comment);
    if (comment.length)
      $(".submit").attr("disabled", false)
    else
      $(".submit").attr("disabled", "disabled")
  )
  return true

Template.comment_toolbar.events
  "focus #text": ()->
    e.stopPropagation()
  "blur #text": ()->
    console.log("blur text")
    Session.set('current_comment_id', '')
  "click .submit": ()->
    $('.new-reply').submit()
  "submit .new-reply": (e)->
    text = e.target.text.value;
    id = e.target.text.attr("postid")
    console.log("postId="+id)
    wifiPost = WifiPosts.findOne('_id': id)
    if wifiPost isnt undefined
      commentId = ""
      for x in [1..32]
        n = Math.floor(Math.random() * 16.0).toString(16)
        commentId += n
      if wifiPost.comments is undefined
        WifiPosts.update {
            _id: wifiPost._id,
          }, {
              $set: {
                comments: [{
                  _id: commentId
                  userId : Meteor.user()._id
                  username: if Meteor.user().profile.nike then Meteor.user().profile.nike else Meteor.user().username
                  userPicture: if Meteor.user().profile.picture then Meteor.user().profile.picture else '/userPicture.png'
                  toUserId: wifiPost.userId
                  toUserName: wifiPost.userName
                  toUserPicture: wifiPost.userPicture
                  comment: text
                  images: []
                  createdAt: new Date()
                }]
              }
          }
      else
        WifiPosts.update {
            _id: wifiPost._id,
          }, {
              $push: {
                comments: {
                  _id: commentId
                  userId : Meteor.user()._id
                  username: if Meteor.user().profile.nike then Meteor.user().profile.nike else Meteor.user().username
                  userPicture: if Meteor.user().profile.picture then Meteor.user().profile.picture else '/userPicture.png'
                  toUserId: wifiPost.userId
                  toUserName: wifiPost.userName
                  toUserPicture: wifiPost.userPicture
                  comment: text
                  images: []
                  createdAt: new Date()
                }
              }
          }
    Session.set('current_comment_id', '')
    return false
