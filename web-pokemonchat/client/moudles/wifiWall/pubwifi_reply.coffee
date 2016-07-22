Router.route(
  '/pubwifi_reply'
  name: 'wifiPubwifiReply'
  layoutTemplate: 'simpleLayout'
  waitOn: ()->
    SubsManager.subscribe 'wifi', Session.get('wifiOnlineId')
    SubsManager.subscribe 'wifiPosts', Session.get('wifiOnlineId')
    SubsManager.subscribe 'wifiUsers', Session.get('wifiOnlineId')
  action: ()->
    this.render()
)

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
      return {heading: '回复公告', placeholder: '回复内容', button: '回复'}
    else
      return {heading: '写点评', placeholder: '评论内容', button: '发表'}



Template.wifiPubwifiReply.events
  'click #btn_back': ()->
    history.go(-1)
  'click .btn-submit': (e)->
    if Wifis.find({_id: Session.get('wifiOnlineId')}).count() is 0
      PUB.toast("系统找不到此小店，您不能在上面评论。")
      return
    text = $('#my_edit_signature').val()
    upload_images = Template.public_upload_index.__helpers.get('images')()

    trackEvent("wifiPubWifi", "Graffiti")
    if(text is '' and upload_images.length == 0)
      PUB.toast('还没有输入任何内容哦~文字或图片都可以~')
    else
      history.go(-1)

      atWho = Template.wifiPubwifiReply.__helpers.get('message')()

      post = {
        userId: Meteor.userId(),
        userName: if Meteor.user().profile.nike then Meteor.user().profile.nike else Meteor.user().username,
        userPicture: if Meteor.user().profile.picture then Meteor.user().profile.picture else '/userPicture.png',
        text: text,
        atWho: atWho
        createTime: new Date(),
        images: upload_images,
        wifiID: Session.get('wifiOnlineId')
      }
      WifiPosts.insert(post)

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
            userType: usertype,
          }
        WifiUsers.insert(userRecord)
      else
        WifiUsers.update({'_id': user._id}, {$set: {createTime: new Date(), userType: usertype}})
