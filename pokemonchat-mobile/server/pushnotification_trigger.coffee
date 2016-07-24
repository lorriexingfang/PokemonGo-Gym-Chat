if Meteor.isServer
  Meteor.startup ()->
    JPush = Meteor.npmRequire "jpush-sdk"
    client = JPush.buildClient 'cc5950acda12cd54ad0e6489', 'c949a9d6f13cb786f4540ec0'

    # 聊天信息推送
    mongoChats.after.insert (userId, doc)->
      if(doc.isPushNotification is undefined or doc.isPushNotification isnt false)
        #console.log('pushnotification...')
        toUserToken = mongoPushToken.findOne({userId: doc.toUserId})
        #console.log(toUserToken)
        if(toUserToken)
          Meteor.defer ()->
            msgStart = ''
            if(doc.msgType isnt 'system' and doc.msgType isnt 'business')
              msgStart = doc.userName + "对您说:"

            extras = {
              type: "chat"
              userId: doc.toUserId
              fromUserId: if doc.userId is undefined then '' else doc.userId
              isBusiness: if doc.msgType is 'business' then true else false
            }
            text = doc.text
            if(text == false)
              text = "[图片]"

            if(toUserToken.type is 'JPush')
              token = toUserToken.token
              client.push().setPlatform 'android'
                .setAudience JPush.registration_id(token)
                .setNotification '消息通知',JPush.ios(msgStart+text,null,null,null,extras),JPush.android(msgStart+text, null, 1,extras)
                #.setMessage(commentText)
                .setOptions null, 60
                .send (err, res)->
                  if err
                    console.log err.message
                  else
                    console.log 'Sendno: ' + res.sendno
                    console.log 'Msg_id: ' + res.msg_id
            else if(toUserToken.type is 'iOS')
              token = toUserToken.token
              #if (toUserToken.whichAPP is 'storebbs')
              pushServer2.sendIOS 'me', token , '', msgStart + text, 1
              #else
              pushServer.sendIOS 'me', token , '', msgStart + text, 1

    WifiPosts.before.insert (userId, doc)->
        #Get wifi information
        title = '消息通知'
        wifi = Wifis.findOne({'_id': doc.wifiID})
        if wifi isnt undefined
            title = wifi.nike
        #Get user name
        userName = doc.userName
        #Get all the users who should be notified.
        allWifiUsers = []
        wifiUsers = WifiUsers.find({'wifiID': doc.wifiID}, {sort: {createTime: -1}}).fetch()
        for item in wifiUsers
          if item.userId is userId
            continue
          isFound = 0
          for item2 in allWifiUsers
            if item2.userId is item.userId
              isFound = 1
              break
          if isFound is 0
            allWifiUsers.push(item)
        superAP = SuperWifis.find({'wifiID': doc.wifiID}, {sort: {createTime: -1}}).fetch()
        for AP in superAP
          wifiUsers = WifiUsers.find({'wifiID': AP.importWifiID}, {sort: {createTime: -1}}).fetch()
          for item in wifiUsers
            if item.userId is userId
              continue
            isFound = 0
            for item2 in allWifiUsers
              if item2.userId is item.userId
                isFound = 1
                break
            if isFound is 0
              allWifiUsers.push(item)
        #console.log("allWifiUsers is : "+JSON.stringify(allWifiUsers))
        myself = WifiUsers.findOne({'userId': userId})
        if myself isnt null and myself isnt undefined
          insertIntoMessage(userId, doc, '我', myself, myself.userId)
        for user in allWifiUsers
          #Insert notification to message bar
          insertIntoMessage(userId, doc, userName, user, user.userId)
          if(doc.isPushNotification is undefined or doc.isPushNotification isnt false)
            sendnotification(userId, doc, title, doc.text, 'wifiPosts', userName, user, user.userId)

    WifiPosts.after.update (userId, doc, fieldNames, modifier, options)->
        #console.log("modifier="+JSON.stringify(modifier))
        #console.log("doc="+JSON.stringify(doc))
        if modifier.$set isnt undefined and modifier.$set isnt null
          commentsData = modifier.$set.comments[0]
        else if modifier.$push isnt undefined and modifier.$push isnt null
          commentsData = modifier.$push.comments
        if commentsData is undefined or commentsData is null
          return
        #Get wifi information
        title = '消息通知'
        wifi = Wifis.findOne({'_id': doc.wifiID})
        if wifi isnt undefined
            title = wifi.nike
        #Get user name
        userName = commentsData.username
        #Get all the users who should be notified.
        allWifiUsers = []
        wifiUsers = WifiUsers.find({'wifiID': doc.wifiID}, {sort: {createTime: -1}}).fetch()
        for item in wifiUsers
          if item.userId is userId
            continue
          isFound = 0
          for item2 in allWifiUsers
            if item2.userId is item.userId
              isFound = 1
              break
          if isFound is 0
            allWifiUsers.push(item)
        superAP = SuperWifis.find({'wifiID': doc.wifiID}, {sort: {createTime: -1}}).fetch()
        for AP in superAP
          wifiUsers = WifiUsers.find({'wifiID': AP.importWifiID}, {sort: {createTime: -1}}).fetch()
          for item in wifiUsers
            if item.userId is userId
              continue
            isFound = 0
            for item2 in allWifiUsers
              if item2.userId is item.userId
                isFound = 1
                break
            if isFound is 0
              allWifiUsers.push(item)
        #console.log("allWifiUsers is : "+JSON.stringify(allWifiUsers))
        myself = WifiUsers.findOne({'userId': userId})
        if myself isnt null and myself isnt undefined
          insertCommentIntoMessage(userId, doc, commentsData, userName, myself, myself.userId)
        for user in allWifiUsers
          #Insert notification to message bar
          insertCommentIntoMessage(userId, doc, commentsData, userName, user, user.userId)
          if(doc.isPushNotification is undefined or doc.isPushNotification isnt false)
            sendnotification(userId, doc, title, commentsData, 'wifiPostsComment', userName, user, user.userId)

    Wifis.after.update (userId, doc, fieldNames, modifier, options)->
        console.log("modifier"+JSON.stringify(modifier))
        console.log("doc="+JSON.stringify(doc))
        
        if modifier.$set isnt undefined and modifier.$set isnt null
          console.log("modifier set is:"+JSON.stringify(modifier))
          shareBy = modifier.$set.sharedBy
          console.log "share name is: "+shareBy

        if shareBy is undefined or shareBy is null
          console.log "share time got nothing! "
          return
        
        title = '消息通知'
        store_name = doc.nike
        store_creator_id = doc.createdBy

        userInfo = WifiUsers.findOne({'userId': store_creator_id})
        userName = userInfo.userName

        text = "店家您好，您的小店" + store_name + "已经被" + shareBy + "分享到Facebook啦!"
        console.log text

        selfUser = Meteor.users.findOne({_id:userId})
        userPicture='/userPicture.png'
        if selfUser.profile.picture then userPicture=selfUser.profile.picture
                        
        incValue = 1   
        if mongoChatUsers.find({userId: userInfo.userId, toUserId: userId}).count() > 0
          mongoChatUsers.update {
          userId: userInfo.userId
          toUserId: userId
          }, {
          $inc: {
          waitReadCount: incValue
          },
          $set: {
          userName: userName
          toUserName: shareBy
          lastText: text
          lastTime: new Date()
          }
          } 
          mongoChatUsers.update {
          userId: userId
          toUserId: userInfo.userId
          }, {
          $set: {
          userName: shareBy
          toUserName: userName
          lastText: text
          lastTime: new Date()
          }
          } 
        else 
          mongoChatUsers.insert {
          userId: userInfo.userId
          userName: userName
          userPicture: userInfo.userPicture
          toUserId: userId
          toUserName: shareBy
          toUserPicture: userPicture
          waitReadCount: 1
          lastText: text
          lastTime: new Date()
          }
          mongoChatUsers.insert {
          userId: userId
          userName: shareBy
          userPicture: userPicture
          toUserId: userInfo.userId
          toUserName: userName
          toUserPicture: userInfo.userPicture
          waitReadCount: 0
          lastText: text
          lastTime: new Date()
          }
    
        mongoChats.insert
                    userId: userId
                    userName: shareBy
                    userPicture: userPicture
                    toUserId: userInfo.userId
                    toUserName: userName
                    toUserPicture: userInfo.userPicture
                    text: text
                    isRead: false
                    readTime: undefined
                    createdAt: new Date()
                    msgType: 'wifiShare'

        sendnotification(userId, doc, title, text, 'wifiShare', shareBy, userInfo, userInfo.userId)

    @sendnotification = (userId, doc, title, commentsData, type, fromUserName, toUser, toUserId)->
      Meteor.defer ()->
        toUserToken = mongoPushToken.findOne({userId: toUserId})
        if toUserToken is undefined
          return
        #generate the message
        text = ''
        images = []
        if type is 'wifiShare'
          msgStart = ""
          text = commentsData
          images = []
        else if type is 'wifiPosts'
          msgStart = fromUserName+": "
          text = doc.text
          images = doc.images || []
        else if type is 'wifiPostsComment'
          msgStart = fromUserName+"回复了"+commentsData.toUserName+": "
          text = commentsData.comment
          images = commentsData.images|| []
        extras = {
          type: type
          userId: toUserId
          fromUserId: userId
          wifiID: doc.wifiID
        }
        if (text != '' && images.length > 0)
          text = "[图片]+"+text
        else if (text != '')
          text = text
        else
          text = "[图片]"

        if(toUserToken.type is 'JPush')
          token = toUserToken.token
          client.push().setPlatform 'android'
            .setAudience JPush.registration_id(token)
            .setNotification title,JPush.ios(msgStart+text,null,null,null,extras),JPush.android(msgStart+text, title, 1,extras)
            #.setMessage(commentText)
            .setOptions null, 60
            .send (err, res)->
              console.log("err="+err+", res="+JSON.stringify(res))
              if err
                console.log err.message
              else
                console.log 'Sendno: ' + res.sendno
                console.log 'Msg_id: ' + res.msg_id
        else if(toUserToken.type is 'iOS')
          token = toUserToken.token
          if (toUserToken.whichAPP is 'storebbs')
            pushServer2.sendIOS title, token , '', msgStart + text, 1
          else
            pushServer.sendIOS title, token , '', msgStart + text, 1
          console.log 'send ios notification'

    @insertIntoMessage = (userId, doc, fromUserName, toUser, toUserId)->
      Meteor.defer ()->
          incValue = 1
          msgType = 'wifiboard'
          #console.log("doc.text="+doc.text+", "+doc.images.length)
          text = doc.text
          if (text != '' && doc.images.length > 0)
            text = fromUserName+": [图片]+"+doc.text
          else if (text != '')
            text = fromUserName+": "+doc.text
          else
            text = fromUserName+": "+"[图片]"
          if userId is toUser.userId
            incValue = 0
          wifi = Wifis.findOne({'_id': doc.wifiID})
          if wifi is undefined or wifi is null
            console.log("Can't find such wifi: "+doc.wifiID);
            return
          if mongoChatUsers.find({userId: toUser.userId, toUserId: doc.wifiID, msgTypeEx: msgType}).count() > 0
              mongoChatUsers.update {
                userId: toUser.userId
                toUserId: doc.wifiID
                msgTypeEx: msgType
              }, {
                $inc: {
                  waitReadCount: incValue
                },
                $set: {
                  toUserName: wifi.nike
                  lastText: text
                  lastTime: doc.createTime
                }
              }
          else
              #if doc.images.length>0 then doc.images[0].url else 'http://localhost.com/fZ8PtzM4rmYJKpCaz_1447184412955_cdv_photo_001.jpg'
              mongoChatUsers.insert {
                userId: toUser.userId
                userName: toUser.userName
                userPicture: toUser.userPicture
                toUserId: doc.wifiID
                toUserName: wifi.nike
                toUserPicture: 'http://localhost.com/fZ8PtzM4rmYJKpCaz_1447184412955_cdv_photo_001.jpg'
                waitReadCount: incValue
                lastText: text
                lastTime: doc.createTime
                msgTypeEx: msgType
              }

    @insertCommentIntoMessage = (userId, doc, commentsData, fromUserName, toUser, toUserId)->
        Meteor.defer ()->
          incValue = 1
          msgType = 'wifiboard'
          if userId is commentsData.toUserId and fromUserName is commentsData.toUserName
            msgStart = fromUserName+"自言自语了"
          else
            msgStart = fromUserName+"回复了"+commentsData.toUserName
          #console.log("insertCommentIntoMessage: commentsData="+JSON.stringify(commentsData))
          text = commentsData.comment
          if (text != '' && commentsData.images.length > 0)
            text = msgStart+": [图片]+"+text
          else if (text != '')
            text = msgStart+": "+text
          else
            text = msgStart+": "+"[图片]"
          if userId is toUser.userId
            incValue = 0
          wifi = Wifis.findOne({'_id': doc.wifiID})
          if wifi is undefined or wifi is null
            console.log("Can't find such wifi: "+doc.wifiID);
            return
          
          #console.log("toUser.userId="+toUser.userId+", doc.wifiID="+doc.wifiID+", msgType="+msgType)
          chatUser = mongoChatUsers.findOne({userId: toUser.userId, toUserId: doc.wifiID, msgTypeEx: msgType})
          selfUser = Meteor.users.findOne(userId)
          #console.log("chatUser="+chatUser)
          if chatUser is undefined or chatUser is null
            insertData = {
                userId: toUser.userId
                userName: toUser.userName
                userPicture: toUser.userPicture
                toUserId: doc.wifiID
                toUserName: wifi.nike
                toUserPicture: 'http://localhost.com/fZ8PtzM4rmYJKpCaz_1447184412955_cdv_photo_001.jpg'
                waitReadCount: incValue
                lastText: text
                lastTime: commentsData.createdAt
                msgTypeEx: msgType
                comments: [{
                    _id: commentId
                    commentId: commentsData._id
                    toUserName: wifi.nike
                    userId: selfUser._id
                    userName: if selfUser.profile.nike then selfUser.profile.nike else selfUser.username
                    userPicture: if selfUser.profile.picture then selfUser.profile.picture else '/userPicture.png'
                    comment: text
                    lastTime: commentsData.createdAt
                }]
            }
            if userId is toUser.userId
              insertData.comments = []
            mongoChatUsers.insert(insertData)
          else
            commentId = ""
            for x in [1..32]
              n = Math.floor(Math.random() * 16.0).toString(16)
              commentId += n
            if chatUser.comments is undefined
              updateData = {
                $inc: {
                  waitReadCount: incValue
                },
                $set: {
                  toUserName: wifi.nike
                  lastText: text
                  lastTime: commentsData.createdAt
                  comments: [{
                    _id: commentId
                    commentId: commentsData._id
                    toUserName: wifi.nike
                    userId: selfUser._id
                    userName: if selfUser.profile.nike then selfUser.profile.nike else selfUser.username
                    userPicture: if selfUser.profile.picture then selfUser.profile.picture else '/userPicture.png'
                    comment: text
                    lastTime: commentsData.createdAt
                  }]
                }
              }
              if userId is toUser.userId
                updateData.comments = []
              mongoChatUsers.update {
                _id: chatUser._id
              }, updateData
            else
              updateData = {
                $inc: {
                  waitReadCount: incValue
                },
                $set: {
                  toUserName: wifi.nike
                  lastText: text
                  lastTime: commentsData.createdAt
                },
                $push: {
                  comments: {
                    _id: commentId
                    commentId: commentsData._id
                    toUserName: wifi.nike
                    userId: selfUser._id
                    userName: if selfUser.profile.nike then selfUser.profile.nike else selfUser.username
                    userPicture: if selfUser.profile.picture then selfUser.profile.picture else '/userPicture.png'
                    comment: text
                    lastTime: commentsData.createdAt
                  }
                }
              }
              if userId is toUser.userId
                delete updateData.$push
              mongoChatUsers.update {
                _id: chatUser._id
              }, updateData
