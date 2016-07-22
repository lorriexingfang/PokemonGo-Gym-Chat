Template.wifiAddWifi.onRendered ()->
  this.$('.set-up').css('min-height', 0)
Template.wifiAddWifi.events
  'click #btn_back': ()->
    window.page.back()
  'click .btn-submit': ()->
    #Session.set('wifiPubWifi_return_view', Session.get('view'))

    nike = $('#wifi_nike').val()
    passwd = $('#wifi_passwd').val()
    signature = $('#wifi_signature').val()

    if(nike is '' or nike is '' or nike is undefined)
        PUB.toast('请给你的小店公告取个名字吧！')
        return

    #更新用户business.wifi
    if(!testDeviceConnectedWifi())
        PUB.toast('当前没有连接到WIFI！')
    else
        navigator.wifi.getConnectedWifiInfo(
            (wifi)->
                wifi.BSSID = wifi.BSSID.toLowerCase()
                if wifi.BSSID isnt ''
                    bssid = wifi.BSSID.toLowerCase().split(':')
                    wifi.BSSID = ''
                    for item in bssid
                        if wifi.BSSID.length > 0
                            wifi.BSSID += ':'
                        if item.length <= 1
                            wifi.BSSID += "0#{item}"
                        else
                            wifi.BSSID += item
                console.log(wifi)
                wifi.nike = nike
                wifi.passwd = passwd
                wifi.signature = signature
                wifi.createTime = new Date()
                wifi.picture = '/wifi/paintingboard.png'
                wifi.type = 1

                if Meteor.user() and Meteor.userId()
                    wifi.createdBy = Meteor.userId()

                location = Session.get('location')
                if location
                    geometry = {type:"Point",coordinates:[location.longitude,location.latitude]}
                else
                    geometry= {type:"Point",coordinates:[0,0]}
                wifi.location = geometry
                wifi.LastActiveTime = new Date()

                showLoading()
                Meteor.call "isBSSIDRegisteredOnBusinessOrGraffiti", wifi.BSSID, (error, result) ->
                      closeLoading()
                      if error
                        PUB.toast('增加失败，请重试！');
                      else if result.result is true
                        PUB.toast(result.reason)
                      else
                        addWifiBottomHalf = ()->
                            wifi = Session.get('addWifiBottomHalf_wifi')
                            upload_images = Template.public_upload_index.__helpers.get('images')()
                            if upload_images isnt undefined and upload_images isnt null and upload_images isnt [] and upload_images.length > 0
                                wifi.latestPicture = upload_images[0].url
                            wfid = Wifis.insert(wifi)

                            createTime = new Date()
                            post = {
                                userId: Meteor.userId(),
                                userName: if Meteor.user().profile.nike then Meteor.user().profile.nike else Meteor.user().username,
                                userPicture: if Meteor.user().profile.picture then Meteor.user().profile.picture else '/userPicture.png',
                                text: wifi.signature,
                                createTime: createTime,
                                images: upload_images,
                                wifiID: wfid,
                                BSSID: wifi.BSSID
                            }
                            WifiPosts.insert(post, (err, postId)->
                              console.log("WifiPosts.insert: add, postId="+postId)
                              if !err
                                if upload_images and upload_images.length > 0
                                  for j in [0..upload_images.length-1]
                                    myTime = new Date((createTime.getTime() + 0))
                                    WifiPhotos.insert({'wifiID': wfid, 'wifiPostId': postId, 'index': j, url: upload_images[j].url, createTime: myTime})
                                    console.log("WifiPhotos.insert: wfid="+wfid+", postId="+postId)
                            )

                            user = WifiUsers.findOne({'userId': Meteor.userId(), 'wifiID':wfid})
                            if (user is undefined)
                                userRecord = {
                                    userId: Meteor.userId(),
                                    userName: if Meteor.user().profile.nike then Meteor.user().profile.nike else Meteor.user().username,
                                    userPicture: if Meteor.user().profile.picture then Meteor.user().profile.picture else '/userPicture.png',
                                    createTime: new Date(),
                                    wifiID: wfid,
                                    BSSID: wifi.BSSID,
                                    visitTimes: 1,
                                    userType: 'user'
                                }
                                WifiUsers.insert(userRecord)
                            else
                                WifiUsers.update({'userId': Meteor.userId()}, {$set: {userType: 'user'}})
                            Session.set('wifiOnlineId', wfid)
                            if Session.get('wifiPubWifi_return')
                                delete Session.keys['wifiPubWifi_return']
                            if Session.get('wifi-pub-wifi-history')
                                delete Session.keys['wifi-pub-wifi-history']
                            Session.set('wifiPubWifi-view', 'wifiPubWifiIndex')
                            Session.set('view', 'wifiPubWifi')
                            if $('#wifi_guide_box').length > 0
                              $('#wifi_guide_box').hide()
                            #addWiFiToWiFiHistory(wfid)
                        
                        Session.set('addWifiBottomHalf_wifi', wifi)
                        upload_images = Template.public_upload_index.__helpers.get('images')()
                        if upload_images.length > 0
                            Template.public_upload_index.__helpers.get('uploadImages')((isSuc)->
                                if isSuc is false
                                    PUB.toast('小店公告图片发表失败，请重新发表。')
                                else
                                    addWifiBottomHalf()
                            )
                        else
                            addWifiBottomHalf()    
                        
            ()->
                PUB.toast('获取Wi-Fi信息失败！');
        )

addWiFiToWiFiHistory = (wifiID)->
    customSubscribe('wifiHistory', Meteor.userId(), wifiID, (type, reason)->
      if type is 'ready'
        if Meteor.userId()?
          wifiUser = WifiHistory.findOne({wifiID:wifiID, userId:Meteor.userId()})
          if wifiUser?
            WifiHistory.update({_id: wifiUser._id}, {$set: {accessAt:new Date()}})
          else
            wifi = Wifis.findOne({'_id': wifiID})
            if wifi?
              wifiUser = wifi
              delete(wifiUser._id)
              wifiUser.wifiID = wifiID
              wifiUser.userId = Meteor.userId()
              wifiUser.accessAt = new Date()
              WifiHistory.insert(wifiUser)
    )
