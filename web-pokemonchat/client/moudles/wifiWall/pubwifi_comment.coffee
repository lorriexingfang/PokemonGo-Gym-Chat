Template.pubwifi_comment.helpers
  show: (id, height)->
    Session.set('hide_footer_bar', true)
    if(!!navigator.userAgent.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/))
      $('.comment-main').css('position', 'relative')
      $('.comment-main').css('bottom', 'auto')
      $('.comment-main').css('height', '62px')
      $('.comment-main .submit').css('bottom', '20px')
    if(id isnt $('.pubwifi-comment-form #posid').val())
      $('.pubwifi-comment-form #text').val('')
    $('.pubwifi-comment-form #posid').val(id)
    $('#wrap').css('overflow', 'hidden')
    $('#wrap').css('height', height)
    $('.pubwifi-comment').css('display', 'block')
    document.body.scrollTop = 999999
    #$('.pubwifi-comment').fadeIn()
  close: (e)->
    $('.pubwifi-comment-form #posid').val('')
    $('.pubwifi-comment-form #text').val('')
    $('.pubwifi-comment').css('display', 'none')
    $('#wrap').css('overflow', 'visible')
    $('#wrap').css('height', 'auto')
    Session.set('hide_footer_bar', false)
  hide: ()->
    $('.pubwifi-comment').css('display', 'none')
    $('#wrap').css('overflow', 'visible')
    $('#wrap').css('height', 'auto')
    Session.set('hide_footer_bar', false)

Template.pubwifi_comment.events
  "blur #text": ()->
    Meteor.setTimeout(
      ()->
        Template.pubwifi_comment.__helpers.get('hide')()
      300
    )
  'click .comment-mask': (e)->
    Template.pubwifi_comment.__helpers.get('hide')()
  'click .submit': ()->
    console.log("Frank: submit")
    $('.pubwifi-comment-form').submit()
  'submit .pubwifi-comment-form': (e)->
    if(e.target.text.value is '')
      PUB.toast('回复内容不能为空！')
    else
      trackEvent("wifiPubWifi", "Add comment")
      text = e.target.text.value
      id = e.target.posid.value
      console.log("postId="+id)
      Template.pubwifi_comment.__helpers.get('close')()
      if (Session.get('wifiPubTipsTmpHided') is true)
        $('.wifi-pub-tips').show()
      wifiPost = WifiPosts.findOne('_id': id)
      if wifiPost isnt undefined
        commentId = ""
        for x in [1..32]
          n = Math.floor(Math.random() * 16.0).toString(16)
          commentId += n
        if wifiPost.comments is undefined
          WifiPosts.update {
              _id: wifiPost._id,
            }, {
                $set: {
                  comments: [{
                    _id: commentId
                    userId : Meteor.user()._id
                    username: if Meteor.user().profile.nike then Meteor.user().profile.nike else Meteor.user().username
                    userPicture: if Meteor.user().profile.picture then Meteor.user().profile.picture else '/userPicture.png'
                    toUserId: wifiPost.userId
                    toUserName: wifiPost.userName
                    toUserPicture: wifiPost.userPicture
                    comment: text
                    images: []
                    createdAt: new Date()
                  }]
                }
            }
        else
          WifiPosts.update {
              _id: wifiPost._id,
            }, {
                $push: {
                  comments: {
                    _id: commentId
                    userId : Meteor.user()._id
                    username: if Meteor.user().profile.nike then Meteor.user().profile.nike else Meteor.user().username
                    userPicture: if Meteor.user().profile.picture then Meteor.user().profile.picture else '/userPicture.png'
                    toUserId: wifiPost.userId
                    toUserName: wifiPost.userName
                    toUserPicture: wifiPost.userPicture
                    comment: text
                    images: []
                    createdAt: new Date()
                  }
                }
            }

    return false
