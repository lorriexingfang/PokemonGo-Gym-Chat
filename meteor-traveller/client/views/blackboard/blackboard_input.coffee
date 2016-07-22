Template.blackboard_input.rendered =->
Template.blackboard_input.events
  'click .leftButton': ->
    Session.set "blackborad_reply_to_userId", undefined
    Session.set "blackborad_footbar_view", "blackboard_footbar_nav"
    window.page.back()
    
  'click .rightButton': ->
    $("#text").focus()
    comment = $('#text').val()
    comment = $.trim(comment)
    if comment is ''
      PUB.toast '请填写内容!'
    else
      $("#new-post-on-blackboard").submit()
    
  'submit .new-post-on-blackboard': (e)->
    if Meteor.user() is null
      PUB.toast '请登录后操作!'
      return
            
    # This function is called when the new task form is submitted
    text = e.target.text.value;
    if text is ""
      # PUB.toast "内容不能为空"
      return false

    console.log('User information is ' + Meteor.user().username)
    token = PushToken.find({userId:Meteor.user()._id}).fetch()
    if token.length >=1
      pushType = token.type
      tokenValue = token.token
    postId = Session.get "blackboard_post_id"
    username = Meteor.user().username
    userId = Meteor.user()._id
    userPicture = ''
    replyId = ""

    for x in [1..32]
      n = Math.floor(Math.random() * 16.0).toString(16)
      replyId += n

    if Meteor.user().profile and Meteor.user().profile.picture
      userPicture = Meteor.user().profile.picture

    try
      cur_post = Posts.findOne(postId)
      if(cur_post.replys == null)
        Posts.update {
          _id: postId,
        }, {
            $set: {
              replys: [{
                _id: replyId
                userId : Meteor.user()._id
                username: if Meteor.user().profile.nike is undefined or Meteor.user().profile.nike is "" then Meteor.user().username else Meteor.user().profile.nike
                toUserId: Session.get("blackborad_reply_to_userId")
                comment: text
                userPicture: userPicture
                createdAt: new Date()
              }]
            }
          }
      else
        Posts.update {
          _id: postId,
        }, {
            $push: {
               replys: {
                 _id: replyId
                 userId : Meteor.user()._id
                 username: if Meteor.user().profile.nike is undefined or Meteor.user().profile.nike is "" then Meteor.user().username else Meteor.user().profile.nike
                 toUserId: Session.get("blackborad_reply_to_userId")
                 comment: text
                 userPicture: userPicture
                 createdAt: new Date()
              }
           }
      }
    catch error
      console.log error
    Session.set "blackborad_reply_to_userId", undefined
    Session.set "blackborad_footbar_view", "blackboard_footbar_nav"
    window.page.back()
    false