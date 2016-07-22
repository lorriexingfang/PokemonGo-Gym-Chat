if Meteor.isServer
  myCrypto = Meteor.npmRequire "crypto"
  Meteor.startup ()->
    process.env.MAIL_URL = 'smtp://xundong_km@163.com:KKactiontec963@smtp.163.com'
    Accounts.emailTemplates.siteName = "Traveller"
    Accounts.emailTemplates.from = "Traveller Admin <xundong_km@163.com>"
    Accounts.emailTemplates.resetPassword.subject = (user)->
        return "重置密码, " + user.profile.nike
    Accounts.emailTemplates.resetPassword.text = (user, url)->
        start = url.indexOf('#')
        sub_str = url.slice(start)
        re_orged_url = 'http://server2.youzhadahuo.com:8080/' + sub_str
        return "点击下面链接, 重置您的密码!\n\n" + re_orged_url
  Meteor.startup ()->
    Meteor.methods
      'existWifiUserByWifi': (id)->
        return WifiUsers.find({userId: this.userId, wifiID: id}).count() > 0
      'getWifiBusinessByKey': (key)->
        k = new RegExp(key)
        return Meteor.users.find(
          {'profile.isBusiness': 1, $or:[
            {'profile.business': k}
            {'profile.address': k}
            {'profile.mobile': k}
          ]}
          {fields: {'profile':1, 'business': 1}, sort: {'business.readCount': -1}, limit: 20}
        ).fetch()
      "getAliyunWritePolicy": (filename, URI)->
        apiKey = 'apikey'
        SecrectKey = 'secrectkey'
        date = new Date()
        content = 'PUT\n\nimage/jpeg\n' + date.toGMTString() + '\n' + '/traveller/'+filename
        hash = myCrypto.createHmac('sha1', SecrectKey).update(content).digest()
        Signture = unescape(encodeURIComponent hash.toString('base64'))
        #console.log 'Content is ' + content + ' Signture ' + Signture
        authheader = "OSS " + apiKey + ":" + Signture
        policy = {
          orignalURI: URI
          date: date.toGMTString()
          auth: authheader
          acceccURI: 'http://oss.youzhadahuo.com/'+filename
        }
        policy
      "getS3WritePolicy": (filename, URI)->
        MAXIMUM_MB = 10
        SECONDS_BEFORE_TIMEOUT = 600
        s3 = new s3Policies 's3key1', 's3key2'
        policy = s3.writePolicy filename,'travelers-bucket', SECONDS_BEFORE_TIMEOUT, MAXIMUM_MB
        policy.orignalURI = URI
        #console.log('return policy ' + JSON.stringify(policy))
        policy
      "getBCSSigniture": (filename,URI)->
        content = "MBO" + "\n"+"Method=PUT" + "\n"+"Bucket=travelers-km" + "\n"+"Object=/" + filename + "\n"
        apiKey = 'bcskey1'
        SecrectKey = 'bcskey2'
        hash = myCrypto.createHmac('sha1', SecrectKey).update(content).digest()
        Signture = encodeURIComponent hash.toString('base64')
        policy = {
          signture: "MBO:"+apiKey+":"+Signture
          orignalURI: URI
        }
        policy
      "getGeoFromConnection":()->
        clientIp = this.connection.clientAddress
        json = GeoIP.lookup clientIp
        console.log('This connection is from ' + clientIp + ' Lookup result + ' + JSON.stringify(json))
        json
      "setChatReadStatusNew":(toUserId, isBusiness)->
        #console.log(isBusiness)
        if(isBusiness)
          Chats.update({toUserId: this.userId, msgType: 'business'}, {$set: {isRead: true, readTime: new Date()}}, {multi: true})
          ChatUsers.update({userId: this.userId, toUserId: toUserId, msgTypeEx: 'business'}, {$set: {waitReadCount: 0}}, {multi: true})
        else
          isSystem = false
          Meteor.users.find({$or: [{username: TRAVELLER_HELPER}, {username: TRAVELLER_BELL}, {username: TRAVELLER_MESSAGE}]}).forEach(
            (user)->
              if(user._id is toUserId)
                isSystem = true
          )

          if(isSystem)
            Chats.update({toUserId: this.userId, msgType: 'system'}, {$set: {isRead: true, readTime: new Date()}}, {multi: true})
            ChatUsers.update({userId: this.userId, toUserId: toUserId, msgTypeEx: 'system'}, {$set: {waitReadCount: 0}}, {multi: true})
          else
            Chats.update({toUserId: this.userId, msgType: {$nin: ['system', 'business']}}, {$set: {isRead: true, readTime: new Date()}}, {multi: true})
            ChatUsers.update({userId: this.userId, toUserId: toUserId, msgTypeEx: {$nin: ['system', 'business']}}, {$set: {waitReadCount: 0}}, {multi: true})
      "setChatReadStatus":(userId, fromUserId)->
        if fromUserId is undefined or fromUserId is ''
          Chats.update({toUserId: userId, msgType: 'system'}, {$set: {isRead: true, readTime: new Date()}}, {multi: true})
          ChatUsers.update({userId: userId, msgType: 'system'}, {$set: {waitReadCount: 0}}, {multi: true})
        else
          Chats.update({toUserId: userId, userId: fromUserId}, {$set: {isRead: true, readTime: new Date()}}, {multi: true})
          ChatUsers.update(
            {
              userId: userId
              toUserId: fromUserId
            }, {
              $set: {waitReadCount: 0}
            }
            {multi: true}
            (error, _id)->
              if error
                console.log "setChatReadStatus error:" + error
          )
        true
      "removePost":(id)->
        #console.log "remove post is '#{id}'"
        #console.log this.userId
        post = Posts.findOne(id)
        if Meteor.user().profile.isAdmin is 1 or post.userId is this.userId
          Posts.remove {_id: id}
          console.log "remove_post is " + id
          true
        else
          false
      "removePostReply":(postId, replyId)->
        if Meteor.user().profile.isAdmin is 1
          post = Posts.findOne {_id: postId}
          for i in [0..post.replys.length]
            if post.replys[i]._id is replyId
              Posts.update {
                _id: postId
              }, {
                $pull: {
                  replys: post.replys[i]
                }
              }
              console.log "remove_post_reply is " + replyId
              break
          true
        else
          false
      sendEmail:(to, from, subject, text)->
        check([to, from, subject, text], [String])
        this.unblock()
        Email.send
          to: to,
          from: from,
          subject: subject,
          text: text
      'findUserByEamil':(email)->
        user = Meteor.users.findOne({'emails.address':email})
      'sendVerificationEmail':(userId, email)->
        Accounts.sendVerificationEmail(userId, email)
      'sendResetPasswordEmail':(userId, email)->
        Accounts.sendResetPasswordEmail userId,email
      # 昵称是否已使用
      'isUserNikeUsed':(nike)->
        Meteor.users.find('profile.nike':nike).count() > 0
      # 判断设备号是否注册2次
      'isDeviceIdUsed':(uuid)->
        if uuid is '' or uuid is undefined
          false
        else
          Meteor.users.find('profile.uuid':uuid).count() >= 2
      # 用户是否已鑜定
      'isLockUser':(username, email)->
        user = Meteor.users.findOne({$or:[{'username':username},{'emails.address':email}]})
        if user is undefined
          false
        user.profile.violation
      'viewWifiBusiness': (id)->
        #console.log(id)
        Meteor.users.update({_id: id}, {$inc: {'business.readCount': 1}})

      "removeWifiReport":(userId, reportId)->
        user = Meteor.users.findOne(userId)
        if(Meteor.user().profile.isAdmin is 1 or userId is this.userId)
          for i in [0..user.business.reports.length]
            if(user.business.reports[i]._id is reportId)
              Meteor.users.update(
                {_id: user._id}
                {$pull: {'business.reports': user.business.reports[i]}}
              )

              if(user.business.reports[i].articleId isnt undefined)
                mongoPosts.remove(user.business.reports[i].articleId)

              return true

          false
      'businessSendGroupMsg': (msg, target)->
        if(this.userId is null)
          return false
        user = Meteor.users.findOne(this.userId)
        time = new Date(Date.parse(new Date()) - WIFI_TIMEOUT - 1*60*6000)
        if(user.profile.isBusiness isnt 1)
          return false
        if(user.business.users is undefined or user.business.users.length <= 0)
          return false
        Meteor.defer ()->
          users = []
          for item in user.business.users
            isSend = false
            users.push(item)
            if(target is 'online-user')
              if(item.updateTime >= time)
                isSend = true
            else
              isSend = true
            if(isSend is true or item.userId is this.userId)
              #console.log("send business message to #{item.userName}.")
              mongoChats.insert(
                {
                  userId: user._id
                  userName: user.profile.business
                  userPicture: user.business.titleImage
                  toUserId: item.userId
                  toUserName: item.userName
                  toUserPicture: item.userPicture
                  text: msg
                  isRead: false
                  readTime: undefined
                  createdAt: new Date()
                  msgType: 'business'
                }
              )

          if user.business.bypassers? and target isnt 'online-user'
            for item in user.business.bypassers
              if(item.userId isnt this.userId)
                exist=0
                for i in users
                  if item.userId is i.userId
                    exist=1
                    break;

                if exist is 0
                  mongoChats.insert(
                    {
                    userId: user._id
                    userName: user.profile.business
                    userPicture: user.business.titleImage
                    toUserId: item.userId
                    toUserName: item.userName
                    toUserPicture: item.userPicture
                    text: msg
                    isRead: false
                    readTime: undefined
                    createdAt: new Date()
                    msgType: 'business'
                    }
                  )

        return true
      'userLogout': (id)->
        Meteor.defer ()->
            user = Meteor.users.findOne(id)
            time = new Date(Date.parse(new Date()) - WIFI_TIMEOUT - 1*60*6000)

            if(user.profile.wifi)
              Meteor.users.update({_id: id}, {$set: {'profile.wifi.status': 'offline'}})
              Meteor.users.find({'business.users.userId': id}).forEach(
                (obj)->
                  if(obj.business.users is undefined or obj.business.users.length <= 0)
                    # TODO:
                  else
                    for i in [0..obj.business.users.length-1]
                      if(obj.business.users[i].userId is id)
                        obj.business.users[i].status = 'offline'
                        break
                    Meteor.users.update({_id: obj._id}, {$set: {'business.users': obj.business.users}})
              )

      'updateAllUserStatus': ()->
        return
#        Meteor.users.find({'business.users.0': {$exists: true}}).forEach(
#          (obj)->
#            time = new Date(Date.parse(new Date()) - WIFI_TIMEOUT - 1*60*6000)
#            for i in [0..obj.business.users.length-1]
#              if(obj.business.users[i].updateTime < time)
#                obj.business.users[i].status = 'offline'
#
#            obj.business.users.sort(
#              (a, b)->
#                b.lastTime - a.lastTime
#            )
#
#            Meteor.users.update({_id: obj._id}, {$set: {'business.users': obj.business.users}})
#        )

      'updateUserStatus': ()->
        Meteor.defer ()->
            if(this.userId is null)
              return

            # 当前wifi商家下的用户处理
            businessUser = Meteor.users.findOne(_id: this.userId)
            time = new Date(Date.parse(new Date()) - WIFI_TIMEOUT - 1*60*6000)

            if(businessUser is undefined)
              return
            if(businessUser.business.users is undefined or businessUser.business.users.length <= 0)
              return

            for i in [0..businessUser.business.users.length-1]
              if(businessUser.business.users[i].updateTime < time)
                businessUser.business.users[i].status = 'offline'

            businessUser.business.users.sort(
              (a, b)->
                b.lastTime - a.lastTime
            )

            Meteor.users.update({_id: businessUser._id}, {$set: {'business.users': businessUser.business.users}})

      'updateUserWifi': (wifi)->
        return

      'updateUserWifiInfo': (wifi)->
        #console.log('updateUserWifi....')
        if(this.userId is null)
          return
          
        wifi = wifi || {}
        time = new Date(Date.parse(new Date()) - WIFI_TIMEOUT - 1*60*6000)

        # 修正IOS下BSSID
        if wifi.BSSID isnt ''
          bssid = wifi.BSSID.toLowerCase().split(':')
          wifi.BSSID = ''
          for item in bssid
            if wifi.BSSID.length > 0
              wifi.BSSID += ':'
            if item.length <= 1
              wifi.BSSID += "0#{item}"
            else
              wifi.BSSID += item
          theWifi = Wifis.findOne({BSSID:wifi.BSSID})
          if theWifi
            updateSession(this.userId, theWifi._id, wifi.BSSID)
            setWifiUserStatus(this.userId, theWifi._id, wifi.BSSID, 'online')

        # 取出原值，如果有
        if(Meteor.user().profile.wifi isnt undefined)
          wifi.createTime = Meteor.user().profile.wifi.createTime
          if(Meteor.user().profile.wifi.status is 'offline')
            wifi.lastTime = new Date()
        else
          wifi.createTime = new Date()

        wifi.status = 'online'
        wifi.updateTime = new Date()
        Meteor.users.update({_id: this.userId}, {$set:{'profile.wifi': wifi}})

        ###
        Meteor.users.update(
          {'profile.wifi.updateTime': {$lt: time}}
          {$set: {'profile.wifi.status': 'offline'}}
          {multi: true}
        )
        ###

        # 当前wifi商家下的用户处理
        businessUser = Meteor.users.findOne({'business.wifi.BSSID': wifi.BSSID})
        if(businessUser is undefined)
          return

        user = {
          userId: this.userId
          userName: if Meteor.user().profile.nike then Meteor.user().profile.nike else Meteor.user().username
          userPicture: if Meteor.user().profile.picture then Meteor.user().profile.picture else '/userPicture.png'
          userSignature: if Meteor.user().profile.signature then Meteor.user().profile.signature else ''
          status: 'online'
          useNumCount: 1
          useDayCount: 1
          createTime: new Date()
          lastTime: new Date()
          updateTime: new Date()
        }
        if(businessUser.business.users is undefined or businessUser.business.users.length <= 0)
          businessUser.business.users = [user]
        else
          exist = false
          for i in [0..businessUser.business.users.length-1]
            # 处理历史数据
            if(businessUser.business.users[i].useNumCount is undefined)
              businessUser.business.users[i].useNumCount = 1
            if(businessUser.business.users[i].useDayCount is undefined)
              businessUser.business.users[i].useDayCount = 1

            if(businessUser.business.users[i].updateTime < time)
              businessUser.business.users[i].status = 'offline'

            if(businessUser.business.users[i].userId is this.userId)
              exist = true
              if(true)
                if((new Date()).getDate() isnt businessUser.business.users[i].lastTime.getDate())
                  businessUser.business.users[i].useDayCount += 1

                businessUser.business.users[i].lastTime = new Date()
                businessUser.business.users[i].status = 'online'
                businessUser.business.users[i].useNumCount += 1

              businessUser.business.users[i].updateTime = new Date()
              businessUser.business.users[i].userPicture = user.userPicture
              businessUser.business.users[i].userName = user.userName
              businessUser.business.users[i].userSignature = user.userSignature
          if(!exist)
            businessUser.business.users.push(user)

        businessUser.business.users.sort(
          (a, b)->
            b.lastTime - a.lastTime
        )

        Meteor.users.update({_id: businessUser._id}, {$set: {'business.users': businessUser.business.users}})

      #when user entered a business store
      'userEnteredBusiness':(uid, bid)->
        console.log 'userEnteredBusiness, uid:bid:thisid,' + uid + ':' + bid + ':' + Meteor.userId()
        user = Meteor.user()
        obj = {
          'userId': user._id
          'userName': user.profile.nike
          'userPicture': user.profile.picture
          'lastTime': new Date()
          'userSignature': ''
        }
        affected = Meteor.users.update({_id: bid, 'business.bypassers.userId': user._id}, {$set: {'business.bypassers.$.lastTime': new Date()}})
        if (affected <= 0)
          Meteor.users.update({_id: bid}, {$addToSet: {'business.bypassers': obj}})
        console.log 'bypasser: ' + JSON.stringify(obj)
      #whether BSSID is registered
      'isBSSIDRegistered':(bssid)->
        console.log 'isBSSIDRegistered, bssid: ' + bssid
        if Meteor.users.find({'business.wifi.BSSID':bssid}).count() > 0
          true
        else
          false
      #whether BSSID is registered as business or graffiti wall
      'isBSSIDRegisteredOnBusinessOrGraffiti':(bssid)->
        ret = {result: false, reason: 'unknown'}
        if Meteor.users.find({'business.wifi.BSSID':bssid}).count() > 0
          ret.result = true
          ret.reason = '此Wifi已被商家绑定，不能添加'
        else if Wifis.find({BSSID:bssid}).count() > 0
          ret.result = true
          ret.reason = '此Wifi已被他人添加，不能添加'
        else
          ret.result = false
          ret.reason = '此Wifi可以添加'
        ret
      #search
      'remoteSearchPosts':(key)->
        console.log 'remoteSearchPosts, key: ' + key
        k = new RegExp(key);
        Posts.find({'type':'pub_board','$or':[{'title':k},{'text':k}]}, {sort: {createdAt: -1},limit:20}).fetch()
      #用户点击商家发布的小黑板时是否推送消息给商家
      'sendBlackboardMsgToBusiness': (text, business)->
        if(withCustomerRequirements)
          user_helper = Meteor.users.findOne({'username': TRAVELLER_BELL})
          user = Meteor.users.findOne(business)
          console.log("Send blackboard message to the merchant '#{user.username}'")
          mongoChats.insert(
            {
              userId: user_helper._id
              userName: user_helper.profile.nike
              userPicture: user_helper.profile.picture
              toUserId: user._id
              toUserName: if user.profile.nike then user.profile.nike else user.profile.username
              toUserPicture: if user.profile.picture then user.profile.picture else '/user.png'
              text: text
              isRead: false
              readTime: undefined
              createdAt: new Date()
              msgType: 'system'
            }
          )
      #群发消息
      'sendGroupMessage':(text, target, parameters, isTest)->
        user_helper = Meteor.users.findOne({'username': TRAVELLER_HELPER})

        if Meteor.user().profile and Meteor.user().profile.isAdmin is 1
          # 发给所有用户
          console.log "pushnotification to #{target} param: #{parameters}"
          JPush = Meteor.npmRequire "jpush-sdk"
          client = JPush.buildClient 'cc5950acda12cd54ad0e6489', 'c949a9d6f13cb786f4540ec0'
          isTest = isTest || false

          if isTest
            # 测试的JPush Key
            # client = JPush.buildClient 'ca668e313d16c914e5eb6b53', '48d18c5a862e4622dae39913'
            testUsers = Meteor.users.find({'profile.isTestUser': true}).fetch()
            testUserIds = new Array()
            for item in testUsers
              testUserIds.push item._id

          if target is 'AllUser' or target is '' or target is null or target is undefined
            #此过程比较耗时，先返回
            Meteor.defer ()->
              if isTest
                users = Meteor.users.find({'profile.isTestUser': true})
              else
                # 发给所有人
                users = Meteor.users.find({})
              console.log "Start sending system message(#{users.length})"

              users.forEach(
                (item)->
                  nike = item.username
                  unless item.profile is undefined or item.profile.nike is undefined
                    nike = item.profile.nike
                  picture = undefined
                  unless item.profile is undefined or item.profile.picture is undefined
                    picture = item.profile.picture

                  mongoChats.insert
                    userId: user_helper._id
                    userName: user_helper.profile.nike
                    userPicture: user_helper.profile.picture
                    toUserId: item._id
                    toUserName: nike
                    toUserPicture: picture
                    text: text
                    isRead: false
                    readTime: undefined
                    createdAt: new Date()
                    msgType: 'system'

                  console.log "The sending system message to '#{item.username}'"
              )
              console.log "The system message send completion"
            true
          else if target is 'Android'
            Meteor.defer ()->
              extras = parameters || {type: 'tips'} # 提示通知，不作任务处理
              # 消息参数样例
              # extras = {
              #   type: "page" # 消息类型，必填
              #   view: '' # 视图名称，必填
              #   param: {} # 视图的参数列表，必填
              #   isLogin: true/false # 是否需要登录，必填
              # }
              console.log "pushnotification to all android."

              if isTest
                pushTokens = mongoPushToken.find({userId: {$in: testUserIds}, type: 'JPush'})
                pushTokens.forEach(
                  (pushToken)->
                    token = pushToken.token

                    client.push().setPlatform 'ios', 'android'
                      .setAudience JPush.registration_id(token)
                      .setNotification '消息通知',JPush.ios(text,null,null,null,extras),JPush.android(text, null, 1,extras)
                      #.setMessage(commentText)
                      .setOptions null, 60
                      .send (err, res)->
                        if err
                          console.log err.message
                        else
                          console.log 'Sendno: ' + res.sendno
                          console.log 'Msg_id: ' + res.msg_id
                )
              else
                client.push().setPlatform JPush.ALL
                  .setAudience JPush.ALL
                  .setNotification '消息通知',JPush.ios(text,null,null,null,extras),JPush.android(text, null, 1,extras)
                  #.setMessage(commentText)
                  .setOptions null, 60
                  .send (err, res)->
                    if err
                      console.log err.message
                    else
                      console.log 'Sendno: ' + res.sendno
                      console.log 'Msg_id: ' + res.msg_id
            true
          else if target is 'iOS'
            Meteor.defer ()->
              if isTest
                pushToken = mongoPushToken.find({userId: {$in: testUserIds}, type: 'iOS'})
              else
                pushToken = mongoPushToken.find({type: 'iOS'})

              pushToken.forEach(
                (pushToken)->
                  token = pushToken.token
                  if (pushToken.whichAPP is 'storebbs')
                    pushServer2.sendIOS 'me', token , '', text, 1
                  else
                    pushServer.sendIOS 'me', token , '', text, 1
                  console.log "pushnotification to all iOS: #{token}."
              )
            true
          else
            false
        else
            false
