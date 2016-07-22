Template.chat_input.rendered =->  
Template.chat_input.helpers
  isPrevAP: ->
    return Session.equals('chat_return_view', 'wifiPubWifi')
  title:->
    # 和谁聊天
    #Meteor.subscribe "userinfo", Session.get("chat_to_userId"), ()->
    #toUser = Meteor.users.findOne {_id: Session.get("chat_to_userId")}
    toUser = serverPushedUserInfo.findOne({_id: Session.get("chat_to_userId")})

    if toUser is undefined or toUser is null
      Meteor.subscribe "userinfo", Session.get("chat_to_userId"), ()->
      toUser = Meteor.users.findOne {_id: Session.get("chat_to_userId")}

    if Session.get("chat_to_userId") is undefined or Session.get("chat_to_userId") is ''
      '系统消息'
    else if toUser.profile.isBusiness and toUser.profile.isBusiness is 1 and Session.get('chat_home_business') is true
      "[#{toUser.profile.business}]#{if toUser.profile.nike then toUser.profile.nike else toUser.profile.nike}"
    else if toUser.profile.nike is undefined or toUser.profile.nike is ""
      toUser.username
    else
      toUser.profile.nike
        
Template.chat_input.events
  'click .leftButton': ->
    window.page.back()
    
  'click .rightButton': ->
    $("#text").focus()
    $("#new-post-on-blackboard").submit()
    
  'submit .new-post-on-blackboard': (e)->
    if Session.get("chat_to_userId") is undefined or Session.get("chat_to_userId") is ''
      PUB.toast '系统消息不能回复!'
      return false

    text = e.target.text.value
    if text is ""
      #PUB.toast '内容不能为空!'
      return false

    Meteor.subscribe 'userToken', Session.get("chat_to_userId"), ()->
    #Meteor.subscribe "userinfo", Session.get("chat_to_userId"), ()->
    #toUser = Meteor.users.findOne {_id: Session.get("chat_to_userId")}
    toUser = serverPushedUserInfo.findOne({_id: Session.get("chat_to_userId")});

    if toUser is undefined or toUser is null
      Meteor.subscribe "userinfo", Session.get("chat_to_userId"), ()->
      toUser = Meteor.users.findOne {_id: Session.get("chat_to_userId")}    

    registrationID = Session.get 'registrationID'
    registrationType = Session.get 'registrationType'
    userToken = {type:registrationType,token:registrationID}
    toUserToken = PushToken.findOne({userId:toUser._id})
    if toUserToken is undefined
      toUserToken = {}

    Chats.insert
      userId: Meteor.user()._id
      userToken: userToken
      userName: if Meteor.user().profile.nike is undefined or Meteor.user().profile.nike is "" then Meteor.user().username else Meteor.user().profile.nike
      userPicture: Meteor.user().profile.picture
      toUserId: toUser._id
      toUserToken: toUserToken
      toUserName: if toUser.profile.nike is undefined or toUser.profile.nike is "" then toUser.username else toUser.profile.nike
      toUserPicture: toUser.profile.picture
      text: text
      isRead: false
      readTime: undefined
      createdAt: new Date()
    
    window.page.back()
    false
    