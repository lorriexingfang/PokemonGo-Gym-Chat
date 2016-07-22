$(window).scroll ()->
  scrollTop = $(this).scrollTop()
  scrollHeight = $(document).height()
  windowHeight = $(this).height()

  #console.log("view: " + Session.get('view'))
  #console.log("wifiPubWifi-view: " + Session.get('wifiPubWifi-view'))
  #console.log("wifiUserWifiNearby_filter: " + Session.get('wifiUserWifiNearby_filter'))

  if(scrollTop >= scrollHeight-windowHeight and
      (Session.equals('view', 'wifiOffline') or
      (Session.equals('view', 'pub_board') and Session.equals('pview', 'wifiOffline')) or
      (Session.equals('view', 'wifiUserWifi') and Session.equals('wifiPubWifi-view', 'wifiUserWifiNearby') and Session.equals('wifiUserWifiNearby_filter', 'AP')) or
      (Session.equals('view', 'wifiUserWifi') and Session.equals('wifiPubWifi-view', 'wifiPubWifiIndex')) or
      (Session.equals('view', 'wifiPubWifi') and Session.equals('wifiPubWifi-view', 'wifiUserWifiNearby') and Session.equals('wifiUserWifiNearby_filter', 'AP')) or
      (Session.equals('view', 'partner_finding') and Session.equals('pview', 'wifiOffline'))
      ))
    limit = Session.get('wifi_off_line_limit') + 10
    Session.set('wifi_off_line_limit', limit)
    $load_more_wifi_off_line = $('#load-more-wifi_off_line')

    $load_more_wifi_off_line.html('加载中，请稍候...')
    if Meteor.status().connected
      $.when(
        location = Session.get('location')
        if location
            geometry = {type:"Point",coordinates:[location.longitude,location.latitude]}
        else
            geometry= {type:"Point",coordinates:[0,0]}
        customSubscribe('guest_user_wifi', geometry.coordinates, limit)
      ).done(()->
        $load_more_wifi_off_line.html('上拉加载更多')
      ).fail(()->
        $load_more_wifi_off_line.html('上拉加载更多')
      )

Session.setDefault('wifi_off_line_subscribe', false)
Template.wifiOffline.created =->
  Session.set('wifi_off_line_limit', 10)
Template.wifiOffline.rendered = ()->
  Session.set('wifi_off_line_loading', true)
  if Meteor.status().connected
    $.when(
      location = Session.get('location')
      if location
          geometry = {type:"Point",coordinates:[location.longitude,location.latitude]}
      else
          geometry= {type:"Point",coordinates:[0,0]}
      customSubscribe('guest_user_wifi', geometry.coordinates, Session.get('wifi_off_line_limit'))
    ).done(()->
      Session.set('wifi_off_line_loading', false)
      Session.set('wifi_off_line_subscribe', true)
    ).fail(()->
      Session.set('wifi_off_line_loading', false)
      Session.set('wifi_off_line_subscribe', true)
    )
  this.$('.list').css('min-height', ($('body').height() - this.$('.tips').height() - 96))
Template.wifiOffline.helpers
  loading: ()->
    Session.equals('wifi_off_line_loading', true)
  no_load: ()->
    !Session.equals('wifi_off_line_subscribe', true)
  data: (obj)->
    obj.count() > 0
  iswifi_style:()->
    if(Session.equals('view', 'wifiOffline'))
      'padding-top: 48px;'
    else
      ''
  iswifi:()->
    Session.equals('view', 'wifiOffline')
  get_distance: (val)->
    location = Session.get('location')
    alert(val+'-'+location)
    if(val isnt undefined and location isnt undefined)
      distance(location.longitude, location.latitude, val.coordinates[0], val.coordinates[1])
    else
      ''
  users: ()->
    limit = Session.get('wifi_off_line_limit')
    if Session.get('wifiSortByWay') is undefined or Session.get('wifiSortByWay') is 'wifiSortByAll'
      Meteor.users.find({'profile.isBusiness': 1, 'business.wifi.0': {$exists: true}}, { limit: limit})
    else if Session.get('wifiSortByWay') is 'wifiSortByNearby'
      Meteor.users.find({'profile.isBusiness': 1, 'business.wifi.0': {$exists: true}}, {sort: {'business.readCount': -1}, limit: limit})
  count: (users)->
    count = 0
    for item in users
      if(item.status is 'online')
        count += 1

    count
  showBack: ()->
    Session.equals('wifiOffline-showBack', true)
Template.wifiOffline.events
  'click .sortby': ()->
    if Session.get('wifiSortByWay') is undefined
      Session.set 'wifiSortByWay', 'wifiSortByAll'
    Session.set('view', 'wifiSortBy')
  'click .seach .input': ()->
    Session.set('wifi-seach-return-view', Session.get('view'))
    Session.set('wifi_seach_limit', 0)
    Session.set('last_search_key', '')
    Session.set('view', 'wifiSeach')
  'click .list li': (e)->
    Meteor.call('viewWifiBusiness', e.currentTarget.id)
    Session.set('online-view', 'wifiOnlineText')
    Session.set('wifiOnlineId', e.currentTarget.id)
    Session.set('BusinessNotFromTuya', true)
    #Session.set('view', 'wifiOnline')
    PUB.page("wifiOnline")
  'click .leftButton': ()->
    Session.set('view', 'wifiPubWifi')
