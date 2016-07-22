root = exports ? this

Session.setDefault('wifiPubWifi-view', 'wifiPubWifiIndex')
mySwiper = null

Template.wifiPubWifi.rendered = ->
  self = this
  mySwiper = new Swiper(
    '.swiper-container'
    {
      pagination: '.swiper-pagination'
      paginationClickable: true
      autoplay: 2000
    }
  )
  self.autorun(() ->
    data = Template.currentData()
    console.log("wifiPubWifi rendered");
    Meteor.setTimeout(()->
      Template.wifiPubWifiIndex.__helpers.get('updatePagination')();
    , 500);
    ###
    Meteor.setTimeout(()->
      self.$("img.lazy").lazyload({effect: "fadeIn", effectspeed: 600, threshold: 800})
    , 100)
    ###
  )
  ##increase access count number
  if Template.currentData() and Template.currentData()._id
    Wifis.update({_id: Template.currentData()._id}, {$inc: {visitCount: 1}})
  if !Session.get('wifiOnlineId')
    $('.tips-index').remove()
    $('.footer').remove()
    $('#wrap').css('padding-top', '0px')
  if $('.wifi-pub-tips').length > 0
    $('#wrap').css('padding-bottom', 80)
  else if $('.wifi-pub-tips-en').length > 0
    $('#wrap').css('padding-bottom', 100)
  else
    $('#wrap').css('padding-bottom', 48)

  console.log("wifiOnlineId="+Session.get('wifiOnlineId'))
  wifi = Wifis.findOne({_id: Session.get('wifiOnlineId')})
  if wifi
    if this.data and this.data.from is 'wuxianbao'
      trackPage('http://server2.youzhadahuo.com:443/wuxianbao/'+wifi.BSSID, '店家: '+wifi.nike)
    else
      trackPage('http://server2.youzhadahuo.com:443/pubwifi/'+Session.get('wifiOnlineId'), '分享: '+wifi.nike)
  else
    if this.data and this.data.from is 'wuxianbao'
      trackPage('http://server2.youzhadahuo.com:443/wuxianbao/'+Session.get('wifiURLPage'), '店家路由器访问（这个Mac地址'+Session.get('wifiURLPage')+'未创建首页）')
    else
      trackPage('http://server2.youzhadahuo.com:443/pubwifi/'+Session.get('wifiOnlineId'), '分享访问（这个ID '+Session.get('wifiOnlineId')+'未创建首页）')

  #Template.popup.__helpers.get('show')('pubwifiIndexHint')


Template.wifiPubWifi.helpers
  isNotWeixin: ()->
    if Session.get('inetAccessAuthed') is true
      return false;
    strArray = window.navigator.userAgent.toLowerCase().match(/MicroMessenger/i)
    if strArray and strArray.length is 1 and strArray[0] is 'micromessenger'
      return false
    if this.from is 'wuxianbao'
      return true
    else
      return false
  isCreatedWifiBoard: ()->
    if Session.get('wifiOnlineId')
      return true
    else
      return false
  template: ()->
    Session.get('wifiPubWifi-view')
  isChannel: (val)->
    Session.equals('wifiPubWifi-view', val)
Template.wifiPubWifi.events
  'click .download': ()->
    is_weixn=()->
      ua = navigator.userAgent.toLowerCase()
      strArray = ua.match(/MicroMessenger/i)
      if strArray and strArray.length is 1 and strArray[0] is 'micromessenger'
        return true
      else
        return false
    if is_weixn()
      PUB.toast2('由于微信进行了限制，请使用浏览器打开后下载本APP。')
      #return
    u = navigator.userAgent
    isAndroid = u.indexOf('Android') > -1               #android
    isiOS = !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/)  #ios
    if !isiOS and !isAndroid
      PUB.toast2('很抱歉，目前仅支持iPhone和Android用户下载该APP。')
      #return
    #PUB.toast2('正在授权访问因特网...')
    trackEvent("wifiPubWifi", "Click download APP")
    $.ajax({
        #url: "http://192.168.98.254/cgi-bin/ip.cgi",
        url: "http://"+Session.get('wifiGWAddress')+":2060/wifidog/auth?token="+Session.get('wifiToken')
        type: 'POST',
        #data: 'username=admin&password=admin1',
        dataType: 'json',
        success: (response)->
            PUB.longtoast('授权成功！正在转到APP下载页面...')
            $('.wifi-pub-tips').hide()
            $('.wifi-pub-tips-en').hide()
            Session.set('inetAccessAuthed', true)
            if isAndroid
              window.location = 'http://app.qq.com/#id=detail&appid=1105002882'
              #window.open('http://app.qq.com/#id=detail&appid=1105002882')
            else if isiOS
              # window.location = 'https://itunes.apple.com/cn/app/id1058218641'
              window.location = 'http://app.qq.com/#id=detail&appid=1105002882'
              #window.open('https://itunes.apple.com/cn/app/id1058218641')
            #if Session.get('wifiOnlineId')
            #  Router.go('scoresSubmitTips', {_id: Session.get('wifiOnlineId')})
        ,
        error: (err)->
            PUB.longtoast('授权成功！正在转到APP下载页面...')
            $('.wifi-pub-tips').hide()
            $('.wifi-pub-tips-en').hide()
            Session.set('inetAccessAuthed', true)
            if isAndroid
              window.location = 'http://app.qq.com/#id=detail&appid=1105002882'
              #window.open('http://app.qq.com/#id=detail&appid=1105002882')
            else if isiOS
              window.location = 'http://app.qq.com/#id=detail&appid=1105002882'
              # window.location = 'https://itunes.apple.com/cn/app/id1058218641'
              #window.open('https://itunes.apple.com/cn/app/id1058218641')
            #if Session.get('wifiOnlineId')
            #  Router.go('scoresSubmitTips', {_id: Session.get('wifiOnlineId')})
    })
    #window.location = 'http://server2.youzhadahuo.com:443/welcome.html'
  'click .btn-close': (e, t)->
    u = navigator.userAgent
    isAndroid = u.indexOf('Android') > -1               #android
    isiOS = !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/)  #ios
    #PUB.toast2('正在授权访问因特网...')
    trackEvent("wifiPubWifi", "Click access internet directly")
    $.ajax({
        #url: "http://192.168.98.254/cgi-bin/ip.cgi",
        url: "http://"+Session.get('wifiGWAddress')+":2060/wifidog/auth?token="+Session.get('wifiToken')
        type: 'POST',
        crossDomain: true,
        #data: 'username=admin&password=admin1',
        dataType: 'html',
        success: (response)->
            PUB.longtoast('授权成功！下载APP后，注册该WiFi热点为小店，就可以在上面发布公告啦！')
            console.log("Auth suc")
            Session.set('inetAccessAuthed', true)
            t.$('.wifi-pub-tips').hide()
            t.$('.wifi-pub-tips-en').hide()
            if isiOS
              window.location = 'http://server2.youzhadahuo.com:443/welcome.html'
        ,
        error: (err)->
            PUB.longtoast('授权成功！下载APP后，注册该WiFi热点为小店，就可以在上面发布公告啦！')
            console.log("Auth failed")
            Session.set('inetAccessAuthed', true)
            t.$('.wifi-pub-tips').hide()
            t.$('.wifi-pub-tips-en').hide()
            if isiOS
              window.location = 'http://server2.youzhadahuo.com:443/welcome.html'
    })

Session.setDefault('wifiPubWifiIndex-view', 'wifiPubWifiIndexWall')

Template.wifiPubWifiIndex.helpers
  gec: (obj)->
    if obj? and obj.address? and obj.address isnt ''
      return obj.address.replace('"', '').replace('"', '')
    else
      if obj? and obj.coordinates?
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
  getTop: ()->
    return'0px'
  updatePagination:->
    for item in Template.wifiPubWifiIndex.__helpers.get('urls')()
      loadImage item.src, {id: item.id}, (params)->
        $("#"+params.id+"_img").removeClass().html("<img src='#{this.src}' />")
    if mySwiper.update?
      mySwiper.update()
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
        if urls[i] and urls[i].src is 'http://data.youzhadahuo.com/fZ8PtzM4rmYJKpCaz_1447184412955_cdv_photo_001.jpg'
            urls.splice(i, 1)

    if urls.length == 0
      urls.push({id: '1234567890smaple',src:'http://data.youzhadahuo.com/fZ8PtzM4rmYJKpCaz_1447184412955_cdv_photo_001.jpg'})

    if urls.length > 6
      for i in [0..5]
        result.push({id: urls[i].id,src: urls[i].src})
    else
        result = urls
    result

Template.wifiPubWifiIndex.events
  'click .wifi-name .add': (e)->
    e.stopPropagation()
    Router.go('/pubwifi_reply')
  'click #two li': (e)->
    Session.set('wifiPubWifiIndex-view', e.currentTarget.id)
  'click .swiper-slide': (e)->
    images = new Array()
    selected = ''
    urls = Template.wifiPubWifiIndex.__helpers.get('urls')()
    for item in urls
      images.push(item.src)
      if(item.id is e.currentTarget.id)
        selected = item.src

    Session.set("images_view_images", images)
    Session.set("images_view_images_selected", selected)
    Template.imagesView.__helpers.get('show')();


Template.wifiPubWifiIndexWall.rendered = ->
  #value = ($(window).width()-20-50-2-2-15)/3
  #$('.con-main .images img').css('width', value)
  #$('.con-main .images img').css('height', value)
  #$('.con-main .images li').css('width', value)
  #$('.con-main .images li').css('height', value)
  self = this
  self.autorun(() ->
    data = Template.currentData()
    console.log("wifiPubWifiIndexWall rendered");
    ###
    setTimeout(()->
      self.$("img.lazy").lazyload({effect: "fadeIn", effectspeed: 600, threshold: 800})
    100)
    ###
  )
  $('.pubwifi-comment .comment-mask').bind((if document.ontouchstart isnt null then 'mousedown' else 'touchstart'), (e)->
      if $('.pubwifi-comment').css('display') isnt 'none'
        #console.log("Frank: active id is "+document.activeElement.id)
        $('.pubwifi-comment-form #text').blur()
        #Template.pubwifi_comment.__helpers.get('close')()
  )


Template.wifiPubWifiIndexWall.helpers
  hasNewComments: (newcomments)->
    if newcomments isnt undefined and newcomments isnt null and newcomments.length > 0
      return true
    else
      return false
  lastImg: (newcomments)->
    if(newcomments[newcomments.length-1].userPicture)
      return newcomments[newcomments.length-1].userPicture
    else
      return '/userPicture.png'
  length: (newcomments)->
    return newcomments.length
  newcomments: ()->
    newcomments = null
    if Meteor.user()
      newcomments = ChatUsers.findOne({userId: Meteor.user()._id, toUserId: Session.get('wifiOnlineId'), msgTypeEx: 'wifiboard'})
    if newcomments is undefined or newcomments is null
      return []
    return newcomments.comments
  posts: ()->
    posts = WifiPosts.find({'wifiID': Session.get('wifiOnlineId')}, {sort: {createTime: -1}}).fetch();
    return posts
  aliasPicture: (pic)->
    if pic is 'userPicture.png'
      return '/userPicture.png'
    return pic
  time: (val)->
    now = new Date()
    GetTime0(now - val)

  isDelete: (val)->
    if Meteor.user()
      userid = Meteor.user()._id
    return userid is val

Template.wifiPubWifiIndexWall.events
  'click #newcomments .title': ()->
    $('#newcomments .title').hide()
    $('#newcomments ul').show()
  'click .to-comment': (e)->
    e.stopPropagation()
    document.body.scrollTop = $(e.currentTarget).offset().top+90+20
  'click span.comment': (e)->
    e.stopPropagation()
    if(Meteor.userId() is null)
      PUB.toast('请登录后操作！')
    #else if(!testDeviceConnectedWifi() or getDeviceWifiBusiness() is undefined or getDeviceWifiBusiness()._id isnt Session.get('wifiOnlineId'))
    #  PUB.toast('请连接到此商家的WIFI后操作！')
    else if (@userId is undefined)
      return
    else
      if($('.wifi-pub-tips').css('display') isnt 'none' or $('.wifi-pub-tips-en').css('display') isnt 'none')
        Session.set('wifiPubTipsTmpHided', true)
        $('.wifi-pub-tips').hide()
        $('.wifi-pub-tips-en').hide()
      ele = $(e.target)
      if(!!navigator.userAgent.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/))
        if($('.usercomments #'+@_id).length > 0)
          Template.pubwifi_comment.__helpers.get('show')(@_id, ele.offset().top+60+$('.usercomments #'+@_id).height())
        else
          Template.pubwifi_comment.__helpers.get('show')(@_id, ele.offset().top+40)
      else
        if($('.usercomments #'+@_id).length > 0)
          Template.pubwifi_comment.__helpers.get('show')(@_id, ele.offset().top+100+$('.usercomments #'+@_id).height())
        else
          Template.pubwifi_comment.__helpers.get('show')(@_id, ele.offset().top+85)
      $('.pubwifi-comment-form #text').focus()
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
    Template.imagesView.__helpers.get('show')();

Template.wifiPubWifiIndexUser.helpers
  posts: ()->
    WifiUsers.find({'wifiID': Session.get('wifiOnlineId')}, {sort: {createTime: -1}}).fetch();
  aliasPicture: (pic)->
    if pic is 'userPicture.png'
      return '/userPicture.png'
    return pic
  time: (val)->
    now = new Date()
    GetTime0(now - val)


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
      if start > 0
        ranks.push(start)
    ranks
  isEq: (p1, p2)->
    p1 == p2
