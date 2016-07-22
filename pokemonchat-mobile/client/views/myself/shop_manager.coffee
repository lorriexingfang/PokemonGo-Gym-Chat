Template.shop_manager.rendered =()->
  Meteor.call('updateUserStatus')
  Meteor.subscribe('ad_list');
Template.shop_manager.helpers
  lists: ->
    if Session.get('articleType') == 'ad'
      Posts.find({type: 'ad', userId: Meteor.user()._id},{sort:{order:-1,createdAt:-1}})
    else
      Posts.find({type: 'notes', tags: {$in: [Session.get('tag')]}},{sort:{createdAt:-1}})
  online: ()->
    if(Meteor.user().business.users is undefined or Meteor.user().business.users.length <= 0)
      return 0
    
    count = 0
    for item in Meteor.user().business.users
      if(item.status is 'online')
        count += 1
    count
  total:()->
    if(Meteor.user().business.users is undefined or Meteor.user().business.users.length <= 0)
      return 0
    
    count = 0
    for item in Meteor.user().business.users
      count += if item.useDayCount then item.useDayCount else 1
    count
  dayCount:()->
    if(Meteor.user().business.users is undefined or Meteor.user().business.users.length <= 0)
      return 0
    
    count = 0
    for item in Meteor.user().business.users
      if(item.updateTime.getDate() is (new Date).getDate())
        count += 1
    count
  totalCount: ()->
    if(Meteor.user().business.users is undefined or Meteor.user().business.users.length <= 0)
      return 0
    
    Meteor.user().business.users.length
Template.shop_manager.events
  'click #adv_mgt':(e)->
    Session.set('articleType', 'ad')
    Session.set('view', 'notes_index')
  'click #wifi_mgt':(e)->
    Session.set('view', 'edit_wifi')
  'click #group_mgt':(e)->
    Session.set('group_msg_send_target', '')
    Session.set('view', 'group_msg_send')
  'click #cur_clients':(e)->
    Session.set('userType', 'online')
    Session.set('view', 'business_user')
  'click #history_clients':(e)->
    Session.set('userType', 'offline')
    Session.set('view', 'business_user')
  'click #ztt_manager':(e)->
    Session.set('view', 'shop_manager_banner')
  'click #business_titleImage':(e)->
    uploadFile(
      (result)->
        console.log("uploadFile " + result)
        if result
          Meteor.users.update Meteor.userId(),{$set:{'business.titleImage':result}}
      1
    )

  'click .leftButton': ->
#      PUB.back()
    window.page.back()
  
Template.shop_manager_banner.helpers
  banners: ()->
    return Meteor.users.findOne(Meteor.userId()).business.banners || []
Template.shop_manager_banner_item.helpers
  is_one: ()->
    return Template.shop_manager_banner.__helpers.get('banners')().length is 1
  is_first: (val)->
    return Template.shop_manager_banner.__helpers.get('banners')()[0].src is val
  is_last: (val)->
    if(Template.shop_manager_banner_item.__helpers.get('is_first')(val))
      return false
    
    banners = Template.shop_manager_banner.__helpers.get('banners')()
    return banners[banners.length-1].src is val     
Template.shop_manager_banner.events
  'click .leftButton': ()->
    window.page.back()
  'click .right-btn': ()->
    if(Template.shop_manager_banner.__helpers.get('banners')().length >=5 )
      PUB.toast('招贴画最多可上传5张！')
    else
      uploadFile(
        (value)->
          banners = Meteor.users.findOne(Meteor.userId()).business.banners || []
          banners.unshift({src: value})
          Meteor.users.update({_id: Meteor.userId()}, {$set: {'business.banners': banners}})
        1
      )
  'click .tips': ()->
    Session.set('view', 'shop_manager_banner_tip')
Template.shop_manager_banner_item.events
  'click .fa-arrow-down': (e)->
    img = $(e.currentTarget).parent().parent().find('img').attr('src')
    banners = Template.shop_manager_banner.__helpers.get('banners')()
    
    if(banners.length > 1)
      for i in [0..banners.length-1]  
        if(banners[i].src is img)
          next = banners[i+1]
          banners.splice(i, 2, next, {src: img})
          Meteor.users.update({_id: Meteor.userId()}, {$set: {'business.banners': banners}})
          break
  'click .fa-arrow-up': (e)->
    img = $(e.currentTarget).parent().parent().find('img').attr('src')
    banners = Template.shop_manager_banner.__helpers.get('banners')()
    
    if(banners.length > 1)
      for i in [0..banners.length-1]  
        if(banners[i].src is img)
          prev = banners[i-1]
          banners.splice(i-1, 2, {src: img}, prev)
          Meteor.users.update({_id: Meteor.userId()}, {$set: {'business.banners': banners}})
          break
  'click .fa-pencil-square-o': (e)->
    img = $(e.currentTarget).parent().parent().find('img').attr('src')
    banners = Template.shop_manager_banner.__helpers.get('banners')()
    
    uploadFile(
      (value)->
        for i in [0..banners.length-1]  
          if(banners[i].src is img)
            banners.splice(i, 1, {src: value})
            Meteor.users.update({_id: Meteor.userId()}, {$set: {'business.banners': banners}})
            break
      1
    )
  'click .fa-trash-o': (e)->
    img = $(e.currentTarget).parent().parent().find('img').attr('src')
    banners = Template.shop_manager_banner.__helpers.get('banners')()
    
    if(banners.length >= 1)
      for i in [0..banners.length-1]  
        if(banners[i].src is img)
          banners.splice(i, 1,)
          Meteor.users.update({_id: Meteor.userId()}, {$set: {'business.banners': banners}})
          break
          
Template.shop_manager_banner_tip.events
  'click .leftButton': ()->
    window.page.back()