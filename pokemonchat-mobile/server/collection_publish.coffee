debug_server_method=false
if Meteor.isServer
  deferToServerPushUserInfo = (cursor,self)->
    Meteor.defer ()->
      cursor.forEach((post)->
        debug_server_method&&console.log('got post ' + post._id)
        if post and post.views
          post.views.forEach((viewedUser)->
            debug_server_method&&console.log('viewedUser ' + viewedUser.userId)
            userInfo = Meteor.users.findOne({_id: viewedUser.userId},{fields: {
              'profile.nike':1,'username':1,'profile.picture':1,'profile.tags':1
              'profile.isVip':1,'profile.isAdmin':1, 'profile.signature':1}});
            if (userInfo)
              try
                this.added('serverPushedUserInfo', userInfo._id, userInfo)
              catch error
                console.log('added error ' + error)
          ,this)
      ,self)
  Meteor.startup ()->
    userHelper = Meteor.users.findOne({username: TRAVELLER_HELPER})
    userBell = Meteor.users.findOne({username: TRAVELLER_BELL})
    userMessage = Meteor.users.findOne({username: TRAVELLER_MESSAGE})
    userNews = Meteor.users.findOne({username: TRAVELLER_NEWS})

    # 获取user的时候 fields 请使用此值，否则第二次的 fields 无法发布到客户端
    user_fields = {'username': 1, 'profile': 1, 'business': 1}

    Meteor.publish "latestFindPartner",()->
      getLatestFindPartner()
    Meteor.publish "postList",()->
      getPostsLists()
    Meteor.publish 'postNew',()->
      getPostsNew()
    Meteor.publish "posts_pub_board",(limit)->
      debug_server_method&&console.log('posts_pub_board with limit' + limit)
      if(limit is null or limit is '' or limit is undefined)
        limit = 50
      Posts.find({type:'pub_board'}, {sort: {createdAt: -1},limit:limit})
    Meteor.publish "posts_local_service",()->
      Posts.find({type:'local_service'}, {sort: {createdAt: -1},limit:50})
    Meteor.publish "posts_activity",()->
      Posts.find({type:'activity'}, {sort: {createdAt: -1}})
    Meteor.publish "posts_theme",(tag)->
      if tag is null or tag is undefined or tag is ''
        []
      else
        Posts.find({type: 'pub_board',"tags.tag":tag}, {sort: {createdAt: -1},limit:50})
    Meteor.publish "posts_about",(lnglat, limit)->
      debug_server_method&&console.log('publishing posts_about ' + JSON.stringify(lnglat) + ' limit ' + limit)
      cursor = []
      if(limit is null or limit is '' or limit is undefined)
        limit = 50
      if lnglat is null or lnglat is undefined or lnglat is '' or lnglat[0] is 0 or lnglat[1] is 0
        cursor = Posts.find({type:"pub_board"},{sort: {createdAt: -1}, limit:limit})
      else
        # 更新用户的位置
#        if(this.userId isnt null)
#          userId = this.userId
#          Meteor.users.update(
#            {_id: userId}
#            {$set: 'profile.lastLocation': {type:"Point", coordinates: lnglat}}
#            (err)->
#              if(err)
#                debug_server_method&&console.log(err)
#              else
#                debug_server_method&&console.log(userId)
#          )

        # 坐标2d查询，60公里 db.posts.ensureIndex({"location.coordinates": "2d"})
        #Posts.ensureIndex({"location.coordinates": "2d"})
        try
          cursor = Posts.find({"location.coordinates":{$near:lnglat,$maxDistance:60/111.12}},type:"pub_board",{sort: {createdAt: -1}, limit:limit})
        catch
          debug_server_method&&console.log('请使用“db.posts.ensureIndex({"location.coordinates": "2d"})”为posts的location建立索引')
      if cursor isnt []
        deferToServerPushUserInfo(cursor,this)
      return cursor
    Meteor.publish 'pushToken', ()->
      PushToken.find({userId: this.userId})
    Meteor.publish "tags",()->
      Tags.find({})
    #Meteor.publish "users",()->
    #  Meteor.users.find({})
    Meteor.publish "chats", ()->
      startTime = new Date()
      startTime.setDate(startTime.getDate() - 7)
      # 最近七天的聊天记录
      Chats.find(
        # 当前登录用户
        {$or: [{userId: this.userId}, {toUserId: this.userId}]}
        # 最近七天
        {sort: {createdAt: -1}, limit: 50}
      )
    Meteor.publish "userChats", (userId, limit, isBusiness)->
      if(userId is undefined or userId is '')
        Chats.find(
          {$or: [{userId: this.userId}, {toUserId: this.userId}]}
          {sort: {createdAt: -1}, limit: limit}
        )
      else if (isBusiness)
        [
          Meteor.users.find({_id: userId},{fields: user_fields})
          Chats.find(
            {$or: [{userId: this.userId, toUserId: userId}, {userId: userId, toUserId: this.userId}]}
            #{$or: [{userId: this.userId, toUserId: userId, msgType: 'business'}, {userId: userId, toUserId: this.userId, msgType: 'business'}]}
            {sort: {createdAt: -1}, limit: limit}
          )
        ]
      else
        [
          Meteor.users.find({_id: userId},{fields: user_fields})
          Chats.find(
            {$or: [{userId: this.userId, toUserId: userId, msgType: {$ne: 'business'}}, {userId: userId, toUserId: this.userId, msgType: {$ne: 'business'}}]}
            {sort: {createdAt: -1}, limit: limit}
          )
        ]
    Meteor.publish "chatUsers", ()->
      debug_server_method&&console.log('chatUsers')
      console.log("this.userId="+this.userId)
      if(this.userId is null)
        return []

      [
        ChatUsers.find({userId: this.userId})
        Meteor.users.find(
          $or: [
            {username: TRAVELLER_HELPER}
            {username: TRAVELLER_BELL}
            {username: TRAVELLER_MESSAGE}
            {username: TRAVELLER_NEWS}
          ]
        )
      ]
    Meteor.publish "userinfo", (id)->
      debug_server_method&&console.log('publishing userinfo ' + id);
      if id is null or id is undefined or id is ''
        []
      else
        Meteor.users.find({_id: id},{fields: user_fields})
    Meteor.publish "userToken", (userId)->
      if userId is null or userId is undefined or userId is ''
        []
      else
        PushToken.find({userId: userId},{fields: {'type':1,'token':1}})
    # 当地人
    Meteor.publish "localserviceUsers",(city,loalCity)->
      debug_server_method&&console.log 'publish localserviceUsers city is ' + city
      if (city is undefined or city is "" or city is "附近") and loalCity isnt undefined
        Meteor.users.find {
          'profile.tags': {$in: ['旅游达人', '客栈', '吃货', '俱乐部']}
          'profile.isVip': 1
          'profile.city': loalCity
        }, {
          fields: user_fields
          sort: {'profile.createdAt': -1}
          limit: 50
        }
      else
        Meteor.users.find {
          'profile.tags': {$in: ['旅游达人', '客栈', '吃货', '俱乐部']}
          'profile.isVip': 1
          'profile.city': city
        }, {
          fields: user_fields
          sort: {'profile.createdAt': -1}
          limit: 50
        }
    # 个人主页
    Meteor.publish 'userHomepage_userInfo', (userId)->
      debug_server_method&&console.log('userHomepage_userInfo is ' + userId)
      return Meteor.users.find({_id: userId}, {fields: user_fields})
    Meteor.publish 'userHomepage_posts', (userId)->
      if userId is null or userId is undefined or userId is ''
        if this.userId is null
          return []
        else
          userId = this.userId

      Posts.find({$or:[{type:'pub_board'},{type:'local_service'}], userId:userId}, {sort: {createdAt: -1},limit:20})
    Meteor.publish 'userHomepage_photos', (userId)->
      if userId is null or userId is undefined or userId is ''
        if this.userId is null
          return []
        else
          userId = this.userId

      Photos.find({userId:userId})
    # 当地人posts
    Meteor.publish 'localservice_posts',(city, lnglat)->
      if (city is undefined or city is "" or city is "附近") and lnglat isnt [0,0]
        Posts.find({type:'local_service',"location.coordinates":{$near:lnglat,$maxDistance:60/111.12}}, {limit:50})
      else
        Posts.find({type:'local_service', city:city}, {sort: {createdAt: -1},limit:50})
    # 商户
    Meteor.publish 'shops',()->
      Meteor.users.find {'profile.isBusiness': 1},{fields:user_fields}
    Meteor.publish 'postInfo',(id)->
      if id is null or id is undefined or id is ''
        []
      else
        Posts.find({_id:id})

    Meteor.publish 'posts_notes',(tag)->
      if tag is null or tag is undefined or tag is ''
        []
      else
        Posts.find({type: 'notes', tags: {$in: [tag]}}, {sort: {createdAt: -1},limit:20})

    Meteor.publish 'seachUsers',(username)->
      if username is null or username is undefined or username is ''
        []
      else
        user = Meteor.users.findOne({_id:this.userId})
        if user.profile.isAdmin is 1
          key = new RegExp(username)
          Meteor.users.find {$or:[{username: key},{'profile.nike': key}]}, {limit:10, fields: user_fields}
        else
          []

    Meteor.publish 'posts_notes_first',(tag)->
      debug_server_method&&console.log "posts_notes_first, tag:'#{tag}' count:#{Posts.find({type: 'notes', tags: {$in: [tag]}}, {sort: {createdAt: -1},limit:1, fields: {title: 1, titleImage: 1, userName: 1}}).count()}"
      Posts.find({type: 'notes', tags: {$in: [tag]}}, {sort: {createdAt: -1},limit:1, fields: {title: 1,type: 1, tags: 1, titleImage: 1, userName: 1}})

#    Meteor.publish 'users_wifi',(wifi)->
#      debug_server_method&&console.log "users_wifi #{Meteor.users.find({'profile.wifi.BSSID': wifi.BSSID}).count()}"
#      Meteor.users.find(
#        {
#          'profile.wifi.BSSID': wifi.BSSID
#        }
#        {fields: {'profile.wifi':1,'profile.nike':1,'profile.isAdmin':1,'profile.mobile':1,'profile.tags':1,'profile.birthday':1, 'profile.sex':1, 'profile.picture':1, 'profile.signature':1, 'profile.city':1, 'profile.isBusiness':1, 'profile.isVip':1}}
#      )

    # 有效活动
    Meteor.publish 'events_effective',()->
      now = new Date()
      Events.find(
        {
          startDate: {$lte: now}
          $or:[
            {endDate: {$gte: now}}
            {endDate: {$exists: false}}
          ]
        }
      )

    Meteor.publish(
      'guest_user_wifi'
      (lnglat, limit)->
        if(limit is null or limit is undefined)
          limit = 10
        try
          #Meteor.users.find({'profile.businessLocation.coordinates': {$near:lnglat,$maxDistance:2000000},'profile.isBusiness': 1}, {fields: user_fields, limit:limit})
          Meteor.users.find({'profile.isBusiness': 1}, {fields: user_fields, sort: {'business.readCount': -1}, limit: limit})
        catch
          console.log('profile.ensureIndex({"profile.businessLocation.coordinates": "2d"})”为Wifis的location建立索引')
          return []
    )

    Meteor.publish(
      'login_user_wifi'
      ()->
        if(this.userId is null)
          return []

        user = Meteor.users.findOne({_id: this.userId})
        if(user is undefined or user.profile is undefined or user.profile.wifi is undefined)
          return []

        debug_server_method&&console.log('login_user_wifi')
        Meteor.users.find({'profile.isBusiness': 1, 'business.wifi.BSSID': user.profile.wifi.BSSID}, {fields: user_fields})
    )
    Meteor.publish(
      'login_user_lan'
      ()->
        if(this.userId is null)
          return []

        user = Meteor.users.findOne({_id: this.userId})
        if(user is undefined or user.profile is undefined or user.profile.wifi is undefined)
          return []

        debug_server_method&&console.log('login_user_lan')
        Meteor.users.find({'profile.wifi.BSSID': user.profile.wifi.BSSID})
    )
    Meteor.publish(
      'wifi_detail_ad'
      (id)->
        debug_server_method&&console.log('wifi_detail_ad')
        [
          Posts.find({type: 'ad', userId: id}, {sort: {order: -1}, limit: 5, fields: {type: 1, userId: 1, images: 1}})
          Meteor.users.find({'profile.isBusiness': 1, _id: id}, {fields: user_fields})
        ]
    )
    Meteor.publish(
      'ad_list'
      ()->
        debug_server_method&&console.log('ad_list')
        Posts.find({type: 'ad', userId: this.userId})
    )

    Meteor.publish(
        'wifiBSSID'
        (id)->
          Wifis.find({BSSID:id})
      )

    domainMacMap = [
      {"domain": "act.com", "macs":["ac:db:00:76:fd:79", "00:18:01:00:52:47", "20:76:00:76:fd:60"]},
      {"domain": "qq.com", "macs":["ac:db:00:76:fd:79", "00:18:01:00:52:47"]}
    ]

    Meteor.publish(
      'wifiLists'
      (bssid, limit)->
        debug_server_method&&console.log(' wifiLists bssid: ' + bssid + '   limit:' + limit)
        if bssid?
          Wifis.find({'BSSID': bssid})
        else if limit?
          #Meteor.users.find({'profile.businessLocation.coordinates': {$near:lnglat,$maxDistance:2000000}}, {limit:limit})
          user = Meteor.users.findOne({_id: this.userId})
          if(user is undefined)
            return []
          udomain = null
          uarr = user.username.split('#')
          if (uarr.length >= 2)
            udomain = uarr[1]
          if udomain
            console.log('##RDBG udomain ' + udomain)
            for dmap in domainMacMap
              if dmap.domain is udomain
                return Wifis.find({BSSID: {$in: dmap.macs}}, {sort: {LastActiveTime: -1}, limit:limit})
          Wifis.find({}, {sort: {LastActiveTime: -1}, limit:limit})
    )

    Meteor.publish(
      'wifiMyBlackboards'
      (createdById, limit)->
        debug_server_method&&console.log(' wifiLists createdById: ' + createdById + '   limit:' + limit)
        if bssid?
          Wifis.find({'createdBy': createdById})
        else if limit?
          #Meteor.users.find({'profile.businessLocation.coordinates': {$near:lnglat,$maxDistance:2000000}}, {limit:limit})
          Wifis.find({'createdBy': createdById}, {sort: {LastActiveTime: -1}, limit:limit})
    )

    Meteor.publish(
      'wifiUsers'
      (id)->
        debug_server_method&&console.log('wifiLists')
        WifiUsers.find({wifiID:id})
    )

    Meteor.publish(
      'wifiPosts'
      (id)->
        console.log('wifiPosts')
        debug_server_method&&console.log('wifiPosts')
        [
          WifiPosts.find({wifiID:id}, {sort: {createTime: -1}})
          WifiPhotos.find({wifiID:id}, {sort: {createTime: -1}})
        ]
    )

    Meteor.publish(
      'wifiPostsLimit'
      (id, limit)->
        debug_server_method&&console.log('wifiPosts')
        wifiPostsCursor = WifiPosts.find({wifiID:id}, {sort: {createTime: -1}, limit: limit})
        wifiPosts = wifiPostsCursor.fetch()
        #console.log("wifiPosts = "+JSON.stringify(wifiPosts));
        if wifiPosts.length > 0
          createTime = wifiPosts[wifiPosts.length-1].createTime
        else
          createTime = new Date()
        [
          wifiPostsCursor
          #WifiPhotos.find({wifiID:id, 'createTime':{$gt:createTime}}, {sort: {createTime: -1}})
        ]
    )

    Meteor.publish(
      'wifiPhotosLimit'
      (id, limit, createTime)->
        console.log('publishWifiPhotos: '+WifiPhotos.find({wifiID:id, 'createTime':{$lt:createTime}}, {sort: {createTime: -1}, limit:limit}).count())
        WifiPhotos.find({wifiID:id, 'createTime':{$lt:createTime}}, {sort: {createTime: -1}, limit:limit})
    )

    Meteor.publish(
      'wifiHistory'
      (id, wifiID, limit)->
        if wifiID is null
          WifiHistory.find({userId:id}, {sort:{accessAt: -1}, limit:limit})
        else
          WifiHistory.find({userId:id, wifiID:wifiID})
    )

    Meteor.publish(
      'wifiFavorite'
      (id, wifiID, limit)->
        if wifiID is null
          if(limit is null)
            WifiFavorite.find({userId:id}, {sort:{accessAt: -1}})
          else
            WifiFavorite.find({userId:id}, {sort:{accessAt: -1}, limit:limit})
        else
          WifiFavorite.find({userId:id, wifiID:wifiID})
    )

    Meteor.publish(
      'userInfoByBSSID'
      (bssid)->
        if bssid?
          Meteor.users.find({'profile.wifi.BSSID': bssid})
    )

    Meteor.publish 'wifiMerchantSearch',(searchText, options)->
        #options2 = {fields: {'profile':1, 'business': 1}, sort: {'business.readCount': -1}, limit: 20};
        options2 = {fields: user_fields, sort: {'business.readCount': -1}, limit: 20};
        if options and options.limit
            options2.limit = options.limit;
        if searchText?
            buildRegExp = (searchText)->
                parts = searchText.trim().split(/[ \-\:]+/);
                return new RegExp("(" + parts.join('|') + ")", "ig");
            regExp = buildRegExp(searchText)
            selector = {$or: [
                {'profile.business': regExp},
                {'profile.address': regExp},
                {'profile.tel': regExp}
                ]};
            Meteor.users.find(selector, options2)
        else
            Meteor.users.find({}, options2)

    Meteor.publish(
      'superAPOne'
      (apId)->
        return SuperWifis.find({'wifiID': apId}, {sort: {createTime: -1}})
    )

    Meteor.publish(
      'superAPByImportWiFiID'
      (apId, importWifiID)->
        return SuperWifis.find({'wifiID': apId, 'importWifiID': importWifiID}, {sort: {createTime: -1}})
    )

    Meteor.publish(
      'getWifiInfoBybssid'
      (bssid)->
        if(bssid)
          return [Wifis.find({'BSSID': bssid}, {limit: 1}), Meteor.users.find({'business.wifi.BSSID': bssid}, {limit: 1})]
        else
          return []
    )

    Meteor.publish(
      'wifiUserOnlineStatus'
      (userIds)->
        Meteor.users.find({_id: {$in: userIds}}, {fields: {'profile.wifi.status':1, 'profile.wifi.updateTime':1}})
    )

    Meteor.publish(
      'wifiScoreByWifiId'
      (id, limit)->
        debug_server_method&&console.log('wifiScore')
        Scores.find({wifiId:id}, {sort: {createdAt: -1}, limit:limit})
    )
    Meteor.publish(
      'my_wallet'
      (limit)->
        debug_server_method&&console.log('my_wallet')
        mongoChats.find({toUserId:this.userId, msgType:'wifiCard'}, {sort: {createdAt: -1}, limit:limit})
    )
