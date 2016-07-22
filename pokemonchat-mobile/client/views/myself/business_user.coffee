Template.business_user.rendered = ()->
  this.$('.main').css('min-height', ($('body').height() - 48 - 48 - 28))
Template.business_user.helpers
  title: ()->
    if Session.get('userType') is 'online' then '当前在店顾客' else '历史顾客'
  users: ()->
    users = []
    for item in Meteor.user().business.users
      if(item.userId is Meteor.userId())
        continue
      if(Session.get('userType') is 'online')
        if(item.status is 'online')
          users.push(item)
      else
        users.push(item)
      
    users
  time: (val)->
    now = new Date()
    GetTime0(now - val)
  noUsers: (obj)->
    obj.length <= 0
  status: (val)->
    if val is 'online' then '在线' else '离线'
Template.business_user.events
  'click .leftButton': ()->
    window.page.back()
  'click .button_right':()->
    if(Session.get('userType') is 'online')
      Session.set('group_msg_send_target', 'online-user')
    else
      Session.set('group_msg_send_target', 'all-user')
    Session.set('view', 'group_msg_send')
  'click .wifi-user li': (e)->
      Session.set "chat_to_userId", e.currentTarget.id
      Session.set 'chat_return_view', Session.get("view")
      PUB.page("chat_home")