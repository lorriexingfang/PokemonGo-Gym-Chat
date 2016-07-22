$(window).scroll ()->
  scrollTop = $(this).scrollTop()
  scrollHeight = $(document).height()
  windowHeight = $(this).height()

  if(scrollTop >= scrollHeight-windowHeight and
      (Session.equals('view', 'wifiOnline') and Session.equals('online-view', 'wifiOnlineReports')
      ))
    if Session.get('wifiOnlineReports_hasMore')
        limit = Session.get('wifiOnlineReports_limit') + 10
        Session.set('wifiOnlineReports_limit', limit)
        $load_more_wifiOnlineReports = $('#load-more-reports')
        $load_more_wifiOnlineReports.html('加载中，请稍候...')
        Meteor.setTimeout (->
            if Session.get('wifiOnlineReports_hasMore')
                $load_more_wifiOnlineReports.html('上拉加载更多')
            else
                $load_more_wifiOnlineReports.html('已加载全部')
        ), 500    

Session.setDefault('online-view', 'wifiOnlineText')
mySwiper = null
wifiOnline_blazeload = null
wifiOnline_scrolltop = null

onUserEnterBusiness = (user, business)->
  if (!user or !business)
    return
  if (user._id is business._id)
    return;
  for item in business.business.wifi
    #under the same wifi as bussiness', no need to treat
    if (user.profile.wifi and user.profile.wifi.BSSID and item.BSSID is user.profile.wifi.BSSID)
      return
  Meteor.call 'userEnteredBusiness', user._id, business._id, (error, result)->
    return
Template.wifiOnline.rendered = ()->
  popup('wifiOnlineHint')
  this.$('.main').css('min-height', $('body').height() - 350)
#  this.find('.swiper-wrapper')._uihooks = {
#    insertElement: (node, next, done)->
#      $(node).hide().insertBefore(next)
#      Template.wifiOnline.__helpers.get('updatePagination')()
#    removeElement: (node, done)->
#      $(node).remove()
#      Template.wifiOnline.__helpers.get('updatePagination')()
#  }
  mySwiper = new Swiper(
    '.swiper-container'
    {
      pagination: '.swiper-pagination'
      paginationClickable: true
      #autoplayDisableOnInteraction : false
      autoplay: 2000
    }
  )
  Session.set('wifiOnlineReports_limit', 10)
  onUserEnterBusiness(Meteor.user(), Meteor.users.findOne(Session.get('wifiOnlineId')))
Template.wifiOnline.helpers
  wifiOnline_blazeload: ()->
    return wifiOnline_blazeload
  notFromTuya: ()->
    if(Session.get('online-return') isnt '' and Session.get('online-return') isnt undefined)
      return true
    else
      return Session.get('BusinessNotFromTuya')
  show: (value)->
    if wifiOnline_blazeload is null
      $('body').append("<div id='wrap2' style='background-color: #fff; min-height: 100%; height: auto;'/>");
      wifiOnline_blazeload = Blaze.render Template.wifiOnline, document.getElementById("wrap2")
      #document.getElementById("wrap");
      #$('body .head').css('z-index', 99999)
      #$('body .wifiOnline').css('position', 'fixed')
      $('body .wifiOnline').css('top', 0)
      $('body .wifiOnline').css('bottom', 0)
      $('body .wifiOnline').css('left', 0)
      $('body .wifiOnline').css('right', 0)
      $('body .wifiOnline').css('padding-bottom', 0)
      $('body .wifiOnline').css('z-index', 999)
      $('body #wrap').css('display', 'none')
      wifiOnline_scrolltop = document.body.scrollTop
      document.body.scrollTop = 0
  close: ()->
    if wifiOnline_blazeload isnt null
      $('body #wrap').css('display', '')
      #$('body .head').css('z-index', 1000)
      $('body .wifiOnline').css('position', 'relative')
      $('body .wifiOnline').css('z-index', 0)
      $('body .wifiOnline').css('padding-bottom', 55)
      Blaze.remove wifiOnline_blazeload
      wifiOnline_blazeload = null
      $('#wrap2').remove();
      document.body.scrollTop = wifiOnline_scrolltop

  updatePagination:->
    for item in Template.wifiOnline.__helpers.get('ad')()
      loadImage item.src, {id: item.id, type: item.type}, (params)->
        $("#"+params.id+"_img").removeClass().html("<img data-type='#{params.type}' src='#{this.src}' />")
    if mySwiper.update?
      mySwiper.update()
  user: ()->
    Meteor.users.findOne(Session.get('wifiOnlineId'))
  template: ()->
    Session.get('online-view')
  isReport: ()->
    Session.equals('online-view', 'wifiOnlineReports')
  isText: ()->
    Session.equals('online-view', 'wifiOnlineText')
  isUser: ()->
    Session.equals('online-view', 'wifiOnlineUsers')
  ad: ()->
    user = Meteor.users.findOne(Session.get('wifiOnlineId'))
    if not user?
      return [] 
    list = Posts.find({type: 'ad', userId: Session.get('wifiOnlineId')}, {sort: {order: -1}, limit: 5}).fetch()
    banners = (user.business.banners if user.business) || []
    result = []
    
    if(banners.length > 0)
      for i in [0..banners.length - 1]
        result.push({id: "#{user._id}_#{i}", type: 'banner', src: banners[i].src})
    if(result.length < 5)
      for item in list
        if(result.length >= 5)
          break
        result.push({id: item._id, type: 'article', src: item.images[0].url})
    if(result.length <= 0)
      #console.log("wifiOnlineId="+Session.get('wifiOnlineId')+", user="+JSON.stringify(user));
      result.push({id: Session.get('wifiOnlineId'), type: 'banner', src: user.business.titleImage})
      
    return result
  titleImage: (obj)->
    obj.images[0].url
  tag: (obj)->
    obj.tags[0]
    
Template.wifiOnline.events
  'click #btn_back': ()->
    window.page.back()
  'click .userwifi-tags li': (e)->
    if(e.currentTarget.id isnt Session.get('wifiOnlineId'))
      Session.set('online-view', e.currentTarget.id)
  'click .rightButton': ()->
    if(Meteor.userId() is null)
      PUB.toast('请登录后操作！')
    else if(Meteor.userId() is Session.get('wifiOnlineId'))
      Session.set("public_upload_index_images", [])
      Session.set('view', 'wifiReport')
    #else if(!testDeviceConnectedWifi() or getDeviceWifiBusiness() is undefined or getDeviceWifiBusiness()._id isnt Session.get('wifiOnlineId'))
    #  PUB.toast('请连接到此商家的WIFI后操作！')
    else
      Session.set("public_upload_index_images", [])
      Session.set('view', 'wifiReport')
  'click .swiper-slide': (e)->
    if($(e.currentTarget).attr('data-type') is 'article')
      Session.set("blackboard_post_id", e.currentTarget.id)
      Session.set('articleType' ,'ad')
      Session.set('articleViewBack' ,'wifiOnline')
      PUB.page("notes_detail", {id: e.currentTarget.id})
    else
      images = new Array()
      selected = ''     
      ad = Template.wifiOnline.__helpers.get('ad')()
      for item in ad
        images.push(item.src)
        if(item.id is e.currentTarget.id)
          selected = item.src
          
      Session.set("images_view_images", images)
      Session.set("images_view_images_selected", selected)
      Session.set("return_view", Session.get("view"))
      Session.set("document.body.scrollTop", document.body.scrollTop)
      if wifiOnline_blazeload isnt null
        Template.wifiOnline.__helpers.get('close')()
      PUB.page("images_view")
    
Template.wifiOnlineText.helpers
  text: ()->
    user = Meteor.users.findOne(Session.get('wifiOnlineId'))
    if user?
      user.profile.text
    else
      ''
  address: ()->
    user = Meteor.users.findOne(Session.get('wifiOnlineId'))
    if user?
      user.profile.address
    else
      ''
  phone_number: ()->
    user = Meteor.users.findOne(Session.get('wifiOnlineId'))
    if user?
      user.profile.tel
    else
      ''

Template.wifiOnlineUsers.helpers
  users: ()->
    users = []
    user = Meteor.users.findOne(Session.get('wifiOnlineId'))
    for item in user.business.users
      if(item.userId isnt Meteor.userId())
        users.push(item)
    if (users.length > 20)
        users = users.slice(0, 20)
    users
  bypassers: ()->
    bypassers = []
    user = Meteor.users.findOne(Session.get('wifiOnlineId'))
    if user? and user.business.bypassers?
        users = []
        for item in user.business.users
            if(item.userId isnt Meteor.userId())
                users.push(item)
                
        for item in user.business.bypassers
            if(item.userId isnt Meteor.userId())
                exist=0
                for i in users
                    if item.userId is i.userId
                        exist=1
                        break;
                if exist is 0
                    bypassers.push(item)
                    
    bypassers.sort (a, b) ->
        new Date(b.lastTime) - new Date(a.lastTime)
    if (bypassers.length > 20)
        bypassers = bypassers.slice(0, 20)
    bypassers
  statusOnline: (val)->
    if val is 'online'
        true
    else
        false
  time: (val)->
    now = new Date()
    GetTime0(now - val)
  noUsers: (obj, obj2)->
    obj.length <= 0 and obj2.length <= 0
Template.wifiOnlineUsers.events
  'click .wifi-user li': (e)->
    if(Meteor.userId() is null)
      PUB.toast('请登录后操作！')
    #else if(!testDeviceConnectedWifi() or getDeviceWifiBusiness() is undefined or getDeviceWifiBusiness()._id isnt Session.get('wifiOnlineId'))
    #  PUB.toast('请连接到此商家的WIFI后操作！')
    else
      if getDeviceWifiBusiness() isnt undefined and getDeviceWifiBusiness isnt null and getDeviceWifiBusiness()._id is Session.get('wifiOnlineId') and getDeviceWifiBusiness()._id is @userId
        Session.set('chat_home_business', true)
      #if Session.get('wifiOnlineId') is @userId
      #  Session.set('chat_home_business', true)
      else
        Session.set('chat_home_business', false)

      Session.set "chat_to_userId", e.currentTarget.id
      Session.set "chat_to_userName", $(this)[0].userName
      Session.set 'chat_return_view', Session.get("view")
      PUB.page "chat_home"
   
Template.wifiOnlineReports.helpers
  has_more_data: ()->
    Session.get('wifiOnlineReports_hasMore')
  is_article: (obj)->
    return obj.articleId
  reports: ()->
    user = Meteor.users.findOne(Session.get('wifiOnlineId'))
    reports = []
    if user? and user.business?
        reports = user.business.reports
        reports = reports.sort(
          (a, b)->
            b.createTime - a.createTime
        )
        limit = Session.get('wifiOnlineReports_limit')
        if (limit is undefined)
            limit = 10
        Session.set('wifiOnlineReports_limit', limit)
        if reports.length > limit
          reports = reports.slice(0, limit)
          has_more = true
        else
          has_more = false;
        Session.set('wifiOnlineReports_hasMore', has_more)
        #reports = reports.sort(
        #  (a, b)->
        #    b.createTime - a.createTime
        #)
    reports
#  reports_bunsiness: ()->
#    reports = Meteor.users.findOne(Session.get('wifiOnlineId')).business.reports
#    reports = reports.sort(
#      (a, b)->
#        b.createTime - a.createTime
#    )
#    for item in reports
#      if(item.userId is Session.get('wifiOnlineId'))
#        console.log(item)
#        return [item]
#
#    return []
  time: (val)->
    now = new Date()
    GetTime0(now - val)
  noReports: (obj)->
    obj.length <= 0
#  is_business: (obj)->
#    obj.userId is Session.get('wifiOnlineId')
  is_remove: ()->
    Meteor.user().profile.isAdmin is 1 or Session.get('wifiOnlineId') is Meteor.userId()
Template.wifiOnlineReports.events
  'click .remove': (e)->
    e.stopPropagation()
    if(!e.currentTarget.id)
      PUB.toast('此条信息无法删除！')
    else
      PUB.confirm(
        '您确定要删除吗？'
        ()->
          Meteor.call(
            'removeWifiReport'
            Session.get('wifiOnlineId')
            e.currentTarget.id
            (err, result)->
              if(err or !result)
                PUB.toast('删除失败！')
              else
                PUB.toast('删除成功！')
                Session.set('wifiOnlineId', getDeviceWifiBusiness()._id);
                Session.set('view', 'wifiOnline')
          )
      )
  'click .report li': (e)->
    if e.currentTarget.className is "photo"
      return
    if($(e.currentTarget).attr('data-article') isnt undefined)
      if(withCustomerRequirements and Meteor.userId() isnt @userId)
        text = (if Meteor.user().profile.nike then Meteor.user().profile.nike else Meteor.user().profile.username) + '查看了你的发布：' + @text
        #console.log(text)
        Meteor.call('sendBlackboardMsgToBusiness', text, @userId)
      
      Session.set("blackboard_post_id", $(e.currentTarget).attr('data-article'))
      Session.set('articleType' ,'ad')
      Session.set('articleViewBack' ,'wifiOnline')
      PUB.page("notes_detail", {id: $(e.currentTarget).attr('data-article')})
    else if(Meteor.userId() is null)
      PUB.toast('请登录后操作！')
    #else if(!testDeviceConnectedWifi() or getDeviceWifiBusiness() is undefined or getDeviceWifiBusiness()._id isnt Session.get('wifiOnlineId'))
    #  PUB.toast('请连接到此商家的WIFI后操作！')
    else if(Meteor.userId() is e.currentTarget.id)
      PUB.toast('不能和自己聊天')
    else
      Session.set "chat_to_userId", e.currentTarget.id
      Session.set 'chat_return_view', Session.get("view")
      PUB.page("chat_home")
  "click .photo img": (e)->
    e.stopPropagation()
    reports = []
    user = Meteor.users.findOne(Session.get('wifiOnlineId'))
    if user? and user.business?
        reports = user.business.reports
        cur_report = null;
        for report in reports
          if(report._id is e.currentTarget.parentNode.parentNode.id)
            console.log(report)
            cur_report = report
            break
        if cur_report is null
          return
        images = new Array();
        cur_report.images.forEach (item)->
          images.push(item.url)
        Session.set("images_view_images", images);
        Session.set("images_view_images_selected", e.currentTarget.src);
        Session.set("return_view", Session.get("view"));
        Session.set("document.body.scrollTop", document.body.scrollTop);
        PUB.page("images_view");

