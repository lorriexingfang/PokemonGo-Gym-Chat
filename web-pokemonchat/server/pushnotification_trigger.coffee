if Meteor.isServer
  Meteor.startup ()->
    JPush = Meteor.npmRequire "jpush-sdk"
    client = JPush.buildClient '35d79a7054c178071c5bb7d8', 'd7a0c462265c3f629ebd68d8'

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
        ###
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
        ###
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
        console.log("userName="+userName+", doc="+JSON.stringify(doc))
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
        ###
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
        ###
        #console.log("allWifiUsers is : "+JSON.stringify(allWifiUsers))
        myself = WifiUsers.findOne({'userId': userId})
        if myself isnt null and myself isnt undefined
          insertCommentIntoMessage(userId, doc, commentsData, userName, myself, myself.userId)
        for user in allWifiUsers
          #Insert notification to message bar
          insertCommentIntoMessage(userId, doc, commentsData, userName, user, user.userId)
          if(doc.isPushNotification is undefined or doc.isPushNotification isnt false)
            sendnotification(userId, doc, title, commentsData, 'wifiPostsComment', userName, user, user.userId)


    @sendnotification = (userId, doc, title, commentsData, type, fromUserName, toUser, toUserId)->
      Meteor.defer ()->
        toUserToken = mongoPushToken.findOne({userId: toUserId})
        if toUserToken is undefined
          return
        #generate the message
        text = ''
        images = []
        if type is 'wifiPosts'
          msgStart = fromUserName+": "
          text = doc.text
          images = doc.images || []
        else if type is 'wifiPostsComment'
          msgStart = fromUserName+"回复了"+commentsData.toUserName+": "
          text = commentsData.comment
          images = commentsData.images || []
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
          #console.log("userId="+userId+", commentsData.toUserId="+commentsData.toUserId+", fromUserName="+fromUserName+", commentsData.toUserName="+commentsData.toUserName)
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
                    toUserName: wifi.nike
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
                    toUserName: wifi.nike
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
                    toUserName: wifi.nike
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