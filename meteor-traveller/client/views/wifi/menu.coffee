Template.wifiPubWifiMenu.helpers
  title: ()->
    if Template.wifiPubWifi.__helpers.get('is_showShare')()
      return Wifis.findOne({_id:Session.get('wifiOnlineId')}).nike
    else if Session.equals('wifiPubWifi-view', 'wifiPubWifiIndex')
      return 'Current'
    else if Session.equals('wifiPubWifi-view', 'wifiUserWifiNearby')
      return 'Nearby'
    else if Session.equals('wifiPubWifi-view', 'wifiUserWifiFavorite')
      return 'Favorite'
    else
      return 'Current'
Template.wifiPubWifiMenu.events
  'click strong': (e, t)->
    t.$('.centent-menu').slideDown()
    t.$('.centent-menu-masker').show()
  'click .centent-menu-masker': (e, t)->
    t.$('.centent-menu-masker').hide()
    t.$('.centent-menu').slideUp()
  'click .centent-menu li': (e, t)->
    t.$('.centent-menu-masker').hide()
    t.$('.centent-menu').slideUp()

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
      
    if e.currentTarget.id isnt 'wifiPubWifiIndex'
      clearNewCommentsMessage(Session.get('wifiOnlineId'))
      Session.set('wifiPubWifiIndex-view', 'wifiPubWifiIndexWall')
      
      if(Session.get('isDialogView', true))
        Session.set('isDialogView', false)
      else if(Template.wifiPubWifi.__helpers.get('isBack')())
        Template.wifiPubWifi.__helpers.get('goBack')()