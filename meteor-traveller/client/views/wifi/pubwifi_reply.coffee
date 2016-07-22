
Template.wifiPubwifiReply.rendered=->
  Template.public_upload_index.__helpers.get('reset')()

Template.wifiPubwifiReply.destroyed = ->
  if Session.get('wifiPubwifiReplyParamMsg')
    delete Session.keys['wifiPubwifiReplyParamMsg']

Template.wifiPubwifiReply.helpers
  message: () ->
    msg = Session.get('wifiPubwifiReplyParamMsg')
    return msg
  titles: () ->
    if Session.get('wifiPubwifiReplyParamMsg')
      return {heading: '{{_ "replay"}}', placeholder: '回复内容', button: '{{_ "replay"}}'}
    else
      return {heading: '写点评', placeholder: '点评内容', button: '发表点评'}



Template.wifiPubwifiReply.events
  'click #wifi_reply_btn_back': ()->
    window.page.back()
  'click .wifi_reply_btn-submit': (e)->

    if Session.get('wifiOnlineId') is undefined or Wifis.find({_id: Session.get('wifiOnlineId')}).count() is 0
      PUB.toast("系统找不到此小店，您不能在上面点评。")
      return
    text = $('#my_edit_signature').val()
    upload_images = Template.public_upload_index.__helpers.get('images')()

    if(text is '' and upload_images.length == 0)
      PUB.toast('还没有输入任何点评内容哦~内容可以是文字或图片哦~')
      return

    postGraffiti = ()->
        upload_images = Template.public_upload_index.__helpers.get('images')()
        if(text is '' and upload_images.length == 0)
          PUB.toast('还没有输入任何点评内容哦~内容可以是文字或图片哦~')
        else
          window.page.back()

          atWho = Template.wifiPubwifiReply.__helpers.get('message')()

          createTime = new Date()
          post = {
            userId: Meteor.userId(),
            userName: if Meteor.user().profile.nike then Meteor.user().profile.nike else Meteor.user().username,
            userPicture: if Meteor.user().profile.picture then Meteor.user().profile.picture else '/userPicture.png',
            text: text,
            atWho: atWho
            createTime: createTime,
            images: upload_images,
            wifiID: Session.get('wifiOnlineId')
          }
          WifiPosts.insert(post, (err, postId)->
            wfid = Session.get('wifiOnlineId')
            console.log("WifiPosts.insert: pub, postId="+postId)
            if !err
              if upload_images and upload_images.length > 0
                for j in [0..upload_images.length-1]
                  myTime = new Date((createTime.getTime() + 0))
                  WifiPhotos.insert({'wifiID': wfid, 'wifiPostId': postId, 'index': j, url: upload_images[j].url, createTime: myTime})
                  console.log("WifiPhotos.insert: wfid="+wfid+", postId="+postId)
          )

          lastestPicture = undefined
          if upload_images isnt undefined and upload_images isnt null and upload_images isnt [] and upload_images.length > 0
            lastestPicture = upload_images[0].url;

          Wifis.update(
              {_id: Session.get('wifiOnlineId')}
              {$set: {'LastActiveTime': new Date(), 'latestPicture': lastestPicture}}
              (err, number)->
                console.log('update LastActiveTime failed');
          )

          usertype = 'bypasser'; # bypasser or user
          onwifi = Wifis.findOne(Session.get('wifiOnlineId'))
          connwifi = Session.get('connectedWiFiInfo')
          if onwifi and connwifi
            if onwifi.BSSID is connwifi.BSSID
                usertype = 'user'
          user = WifiUsers.findOne({'userId': Meteor.userId(), 'wifiID':Session.get('wifiOnlineId')});
          if (user is undefined)
            userRecord = {
                userId: Meteor.userId(),
                userName: if Meteor.user().profile.nike then Meteor.user().profile.nike else Meteor.user().username,
                userPicture: if Meteor.user().profile.picture then Meteor.user().profile.picture else '/userPicture.png',
                createTime: new Date(),
                wifiID: Session.get('wifiOnlineId'),
                visitTimes: 1,
                userType: usertype,
              }
            WifiUsers.insert(userRecord)
          else
            userpic = if Meteor.user().profile.picture then Meteor.user().profile.picture else '/userPicture.png'
            WifiUsers.update({'_id': user._id}, {$set: {createTime: new Date(), userType: usertype, userPicture: userpic}})

    if upload_images.length > 0
      Template.public_upload_index.__helpers.get('uploadImages')((isSuc)->
        if isSuc is false
          PUB.toast('发表失败，请重新发表点评。')
        else
          postGraffiti()
          Session.set('isDialogView', false)
          Session.set('wifiPubWifiIndex-view', 'wifiPubWifiIndexWall')
      )
    else
      postGraffiti()
      Session.set('isDialogView', false)
      Session.set('wifiPubWifiIndex-view', 'wifiPubWifiIndexWall')
