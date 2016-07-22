if Meteor.isServer
  Posts.allow
    insert: (userId,doc)->
      userId is doc.userId
    update: (userId,doc,fieldNames, modifier)->
      if userId is doc.userId and doc.type is 'ad'
        return true
      if userId is doc.userId and doc.type is 'pub_board'
        return true
      if `fieldNames == 'replys'` or `fieldNames == 'reports'` and modifier.$push isnt undefined
        return true
      else if fieldNames.toString() is 'views' or fieldNames.toString() is 'toJoin' or fieldNames.toString() is 'report' and modifier.$set isnt undefined
        return true
      # 点赞
      unless modifier.$inc is undefined or modifier.$inc["report"] is undefined
        return true
      unless modifier.$inc is undefined or modifier.$inc["good"] is undefined
        return true
      false
#  Photos.allow
#    insert: (userId,doc)->
#      userId is doc.userId
#  PushToken.allow
#    insert: (userId,doc)->
#      false
#    update: (userId, doc, fieldNames, modifier)->
#      userId and userId is doc.userId modifier.$set.type and modifier.$set.token
  Meteor.users.allow
    insert: (userId,doc)->
      true
    update: (userId, doc, fieldNames, modifier)->
      console.log(doc._id is userId)
      if(doc._id is userId)
        return true
      # wifi 商家
      if(doc.profile.isBusiness is 1)
        return true
      if(userId is doc.userId)
        return true
      false
#  Chats.allow
#    insert: (userId,doc)->
#      userId is doc.userId
#
#  Events.allow
#    insert: (userId,doc)->
#      false
#    update: (userId, doc, fieldNames, modifier)->
#      false
  ChatUsers.allow
    update: ()->
       true

  Wifis.allow
    insert: (userId,doc)->
      true
    update: (userId, doc, fieldNames, modifier)->
      true
    remove: (userId,doc)->
      postsInsertHookDeferHandle(userId,doc)
      true

  WifiUsers.allow
    insert: (userId,doc)->
      true
    update: (userId, doc, fieldNames, modifier)->
      true

  WifiPosts.allow
    insert: (userId,doc)->
      true
    update: (userId, doc, fieldNames, modifier)->
      true
    remove: (userId,doc)->
      true

#  WifiHistory.allow
#    insert: (userId,doc)->
#      userId is doc.userId
#    update: (userId, doc, fieldNames, modifier)->
#      userId is doc.userId
#  SuperWifis.allow
#    insert: (userId,doc)->
#      #userId is doc.userId
#      true
#    update: (userId, doc, fieldNames, modifier)->
#      userId is doc.userId
#    remove: (userId,doc)->
#      true
      
#  WifiFavorite.allow
#    insert: (userId,doc)->
#      if (userId isnt doc.userId)
#        return false
#      else if(WifiFavorite.findOne({wifiID: doc.wifiID, userId: doc.userId}) isnt undefined)
#        return false
#        #WifiFavorite.update({_id: doc._id}, {$set: {accessAt: new Date()}})
#        #throw new Error('')
#      else
#        return true
#    update: (userId, doc, fieldNames, modifier)->
#      return userId is doc.userId
#    remove: (userId,doc)->
#      return userId is doc.userId

  postsInsertHookDeferHandle = (userId,doc)->
    Meteor.defer(()->
      WifiHistory.remove({'wifiID': doc._id})
      SuperWifis.remove({'importWifiID': doc._id})
      SuperWifis.remove({'wifiID': doc._id})
    )

  Scores.allow
    insert: (userId, doc)->
      return userId is doc.userId
