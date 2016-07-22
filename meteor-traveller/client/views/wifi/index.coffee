Template.wifiIndex.created = ()->
    #console.log('Template.wifiIndex.created')
    #console.log(Session.get('connectedWiFiInfo').SSID)
    # Meteor.call('updateAllUserStatus')
    #updateDeviceWifi()
    # 没有连接WIFI或当前WIFI没有商家
    ###
    $('#wrap').css('height','auto')
    if(!testDeviceConnectedWifi())
    Session.set('wifiOffline-showBack', false)
    Session.set('backView', 'wifiOffline')
    Session.set('view', 'wifiOffline')
    else
    ###
    bssid = '';
    user = getDeviceWifiBusiness()
    if Meteor.userId() is null
      wifiInfo = Session.get('connectedWiFiInfo')
      bssid = if wifiInfo then wifiInfo.BSSID else ''
    else
      if Meteor.user()? and Meteor.user().profile? and Meteor.user().profile.wifi
        bssid = Meteor.user().profile.wifi.BSSID
      else
        bssid = ''

    wifi = Wifis.findOne({'BSSID': bssid});

    if user is undefined and wifi is undefined
      if(!wifiInfo)
        console.log("wifiInfo is null!")
        wifiInfo = {SSID: ''}
      Session.set('wifiPubWifi_return', '')
      #Session.set('wifiPubWifi-view', 'wifiPubWifiIndex')
      Session.set('view', 'wifiPubWifi')
    else
        Session.set('wifiOnlineId', wifi._id)
        Session.set('wifiPubWifi_return', '')
        #Session.set('wifiPubWifi-view', 'wifiPubWifiIndex')
        Session.set('view', 'wifiPubWifi')
