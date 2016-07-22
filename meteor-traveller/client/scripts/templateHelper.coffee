Meteor.startup ->
  # 是否已登录
  Template.registerHelper 'getUserTagImage', (tag)->
    for item in userTags
      if item.name is tag
        return item.image
    ''