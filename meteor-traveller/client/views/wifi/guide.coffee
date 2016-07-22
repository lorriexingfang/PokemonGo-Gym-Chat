Template.wifiGuide.onRendered ()->
  $('#wifi_guide_box').css('height',($('body').height()-0)+'px')
  $('body').css('overflow', 'hidden')
Template.wifiGuide.onDestroyed ()->
  $('body').css('overflow', 'auto')
Template.wifiGuide.helpers
  wifi_name: ()->
    wifi = Session.get('connectedWiFiInfo')
    if wifi
      wifi.SSID.replace('"', '').replace('"', '')
Template.wifiGuide.events
  'click #addHotspot': (e, t)->
    t.$('.hint-text').show()
    t.$('.hint-text-mask').show()
#    if (Meteor.userId() is null)
#      PUB.toast('注册登录后才能创建哦，赶快注册吧！')
#      Session.set('view', 'login')
#      return
#
#    Session.set("public_upload_index_images", [])
#    Session.set('view', 'wifiAddWifi')
  'click .wifihint-tips': (e, t)->
    t.$('.hint-text').show()
    t.$('.hint-text-mask').show()
  'click .hint-text': (e, t)->
    t.$('.hint-text').hide()
    t.$('.hint-text-mask').hide()
  'click .hint-text-mask': (e, t)->
    t.$('.hint-text').hide()
    t.$('.hint-text-mask').hide()
  'click .btn-skip': (e, t)->
    $('#wrap').show()
    $('#footer').show()
    Session.set('wifiPubWifi_return', '')
    Session.set('wifiPubWifi-view', 'wifiUserWifiNearby')
    Session.set('view', 'wifiPubWifi')
    $('#wifi_guide_box').remove()
  'click .btn-yes': (e, t)->
    if (Meteor.userId() is null)
      PUB.toast('注册登录后才能创建哦，赶快注册吧！')
      $('#wifi_guide_box').remove()
      $('#wrap').show()
      $('#footer').show()
      Session.set('view', 'login')
      return

    $('#wifi_guide_box').remove()
    $('#wrap').show()
    $('#footer').show()
    Session.set("public_upload_index_images", [])
    Session.set('view', 'wifiAddWifi')

  'click .create-board': ()->
    if (Meteor.userId() is null)
      PUB.toast('注册登录后才能创建哦，赶快注册吧！')
      Session.set('view', 'login')
      return

    Session.set("public_upload_index_images", [])
    Session.set('view', 'wifiAddWifi')
