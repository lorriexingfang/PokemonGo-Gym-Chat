Template.group_msg_send.helpers
  target: (val)->
    Session.get('group_msg_send_target') is val
Template.group_msg_send.events
  'click .leftButton': ()->
    window.page.back()
  'click .rightButton': ()->
    $('.new-post-on-blackboard').submit()
  'submit .new-post-on-blackboard': (e)->    
    if(e.target.text.value is '')
      PUB.toast '群发内容不能为空!'
      return false
    if(e.target.text.value is '')
      PUB.toast '请选择发送目标!'
      return false

    #Template.public_loading_index.__helpers.get('show')('')
    Meteor.call(
      'businessSendGroupMsg'
      e.target.text.value
      e.target.text.value
      (err, result)->
        #Template.public_loading_index.__helpers.get('close')()
        if(err or !result)
          PUB.toast '发送失败，请重试!'
        else
          PUB.toast '发送成功!'
          window.page.back()
    )

    return false