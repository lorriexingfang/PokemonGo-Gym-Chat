if Meteor.isServer
  Posts.allow
    insert: (userId,doc)->
      false
    update: (userId,doc,fieldNames, modifier)->
      true
  Photos.allow
    insert: (userId,doc)->
      false
    update: (userId,doc,fieldNames, modifier)->
      true
  PushToken.allow
    insert: (userId,doc)->
      false
    update: (userId, doc, fieldNames, modifier)->
      true
  Meteor.users.allow
    insert: (userId,doc)->
      false
    update: (userId, doc, fieldNames, modifier)->
      true
  Chats.allow
    insert: (userId,doc)->
      false
    update: (userId, doc, fieldNames, modifier)->
      true
  Events.allow
    insert: (userId,doc)->
      false
    update: (userId, doc, fieldNames, modifier)->
      true
  ChatUsers.allow
    insert: (userId,doc)->
      false
    update: (userId, doc, fieldNames, modifier)->
      true
  Tags.allow
    insert: (userId,doc)->
      false
    update: (userId, doc, fieldNames, modifier)->
      true
