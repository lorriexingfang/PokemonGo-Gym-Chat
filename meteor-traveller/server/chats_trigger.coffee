if Meteor.isServer
  Meteor.startup ()->
    # 处理最近联系人
    mongoChats.before.insert (userId, doc)->
      if doc.msgType is 'wifiCard'
        user_system = Meteor.users.findOne({username: TRAVELLER_SYSTEM})
        mongoChats.insert(
          {
            userId: user_system._id
            userName: user_system.profile.nike
            userPicture: user_system.profile.picture
            toUserId: doc.toUserId
            toUserName: doc.toUserName
            toUserPicture: doc.toUserPicture
            text: "#{doc.userName}店家送给您一张优惠券，已经帮您存到“我的钱包”啦！"
            isRead: false
            readTime: undefined
            createdAt: new Date()
            msgType: 'system'
            isPushNotification: true
          }
        )
    
      if doc.msgType is 'system' or doc.msgType is 'business'
        # 被拱话者 - 搭伙小助手\游喳小喇叭\搭伙消息等消息
        if mongoChatUsers.find({userId: doc.toUserId, toUserId: doc.userId, msgTypeEx: doc.msgType}).count() > 0
          mongoChatUsers.update {
            userId: doc.toUserId
            toUserId: doc.userId
            msgTypeEx: doc.msgType
          }, {
            $inc: {
              waitReadCount: 1
            },
            $set: {
              lastText: doc.text
              lastTime: doc.createdAt
            }
          }
        else
          mongoChatUsers.insert {
            userId: doc.toUserId
            userName: doc.toUserName
            userPicture: doc.toUserPicture
            toUserId: doc.userId
            toUserName: doc.userName
            toUserPicture: doc.userPicture
            waitReadCount: 1
            lastText: doc.text
            lastTime: doc.createdAt
            msgTypeEx: doc.msgType
          }
      else
        # 搭话者 - 非系统消息
        if mongoChatUsers.find({userId: doc.userId, toUserId: doc.toUserId, msgTypeEx: {$nin: ['system', 'business']}}).count() > 0
          mongoChatUsers.update {
            userId: doc.userId
            toUserId: doc.toUserId
            msgTypeEx: {$nin: ['system', 'business']}
          }, {
            $set: {
              lastText: doc.text
              lastTime: doc.createdAt
            }
          }
        else
          mongoChatUsers.insert {
            userId: doc.userId
            userName: doc.userName
            userPicture: doc.userPicture
            toUserId: doc.toUserId
            toUserName: doc.toUserName
            toUserPicture: doc.toUserPicture
            waitReadCount: 0
            lastText: doc.text
            lastTime: doc.createdAt
          }
        
        # 被搭话者 - 非系统消息
        if mongoChatUsers.find({userId: doc.toUserId, toUserId: doc.userId, msgTypeEx: {$nin: ['system', 'business']}}).count() > 0
          mongoChatUsers.update {
            userId: doc.toUserId
            toUserId: doc.userId
            msgTypeEx: {$nin: ['system', 'business']}
          }, {
            $inc: {
              waitReadCount: 1
            },
            $set: {
              lastText: doc.text
              lastTime: doc.createdAt
            }
          }
        else
          mongoChatUsers.insert {
            userId: doc.toUserId
            userName: doc.toUserName
            userPicture: doc.toUserPicture
            toUserId: doc.userId
            toUserName: doc.userName
            toUserPicture: doc.userPicture
            waitReadCount: 1
            lastText: doc.text
            lastTime: doc.createdAt
          }
      
      