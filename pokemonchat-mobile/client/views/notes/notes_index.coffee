Template.notes_index.helpers
  lists: ->
    if Session.get('articleType') == 'ad'
      Posts.find({type: 'ad', userId: Meteor.user()._id},{sort:{order:-1,createdAt:-1}})
    else
      Posts.find({type: 'notes', tags: {$in: [Session.get('tag')]}},{sort:{createdAt:-1}})
  is_admin:->
    #Meteor.subscribe 'userinfo', Meteor.userId()
    #if Meteor.user() and Meteor.user().profile.isAdmin is 1
    user = serverPushedUserInfo.findOne({_id: Meteor.userId()})

    if user is undefinded or user is null
      Meteor.subscribe 'userinfo', Meteor.userId()
      user = Meteor.user()

    if user && user.profile && user.profile.isAdmin is 1
      return true
    false
  titleName:->
    if Session.get('articleType') == 'ad'
      '我的文章'
    else
      '游记'
  publishBtn:->
    if Session.get('articleType') == 'ad'
      '写文章'
    else
      '发游记'
  isAd:->
    Session.get('articleType') == 'ad'
  is_my:(obj)->
    obj.userId is Meteor.userId()
Template.notes_index.events
  'click .edit': (e)->
    e.stopPropagation()
    console.log("edit note: " + e.currentTarget.id)
    if Meteor.user() is null
      PUB.toast '请登录后操作！'
    else
      PUB.page "notes_edit", {note_id: e.currentTarget.id}
  'click .delete': (e)->
    e.stopPropagation()
    PUB.confirm("你确定要删除吗？", ()->
     Meteor.call "removePost", e.currentTarget.id
  )
  'click .order':(e)->
    $(e.currentTarget).parent().find("#orderArea").show()
    e.stopPropagation()
    return false
  'click .orderSubmit':(e)->
    e.stopPropagation();
    $(e.currentTarget).parent().hide();
    num = $(e.currentTarget).parent().find("#orderNum").val();
    num = parseInt(num);
    id = e.currentTarget.id;
    Posts.update(
      {_id: id}
      {$set:{order:num}}
      (err, number)->
        if(err or number <= 0)
          console.log(err)
    );
  'click #orderNum':(e)->
    e.stopPropagation();
  'click .leftButton': ->
#    PUB.back()
    window.page.back()
  'click .rightButton': ->
    if Meteor.user() is null
      PUB.toast '请登录后操作！'
    else
      PUB.page "notes_add", {tag: Session.get('tag')}
  'click .notes_list': (e)->
    Session.set "blackboard_post_id", e.currentTarget.id
    PUB.page "notes_detail", {id: e.currentTarget.id}