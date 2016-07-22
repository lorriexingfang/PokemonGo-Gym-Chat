if Meteor.isServer
  Meteor.startup ()->
    Accounts.onLogin (object)->
      # if Anonymous user with default icon, changed to a better one.
      if object.user
        ###
        Since All anonymose name were changed on server side, no need to check it every time.
        if object.user.profile and object.user.profile.anonymous
          if object.user.profile.icon is '/userPicture.png'
            randomI = parseInt(Math.random()*33+1)
            icon = 'http://data.tiegushi.com/anonymousIcon/anonymous_' + randomI + '.png'
            Meteor.users.update {_id:object.user._id},{$set:{'profile.icon':icon}}
          if object.user.profile.fullname is '匿名'
            newName = getRandomAnonymousName()
            if newName and newName isnt ''
              Meteor.users.update {_id:object.user._id},{$set:{'profile.fullname':newName}}
        ###
        if object.connection and object.connection.clientAddress
          loginSession(object.connection, new Date(), object.user._id)
          Meteor.users.update {_id:object.user._id},{$set:{'profile.lastLogonIP':object.connection.clientAddress}}


  @setWifiUserStatus = (userId, wifiID, bssid, status)->
    #console.log("setWifiUserStatus: userId="+userId+", wifiID="+wifiID+", status="+status)
    userType = 'bypasser'
    if status is 'online'
      userType = 'user'
    theUser = WifiUsers.findOne({'userId': userId, 'wifiID':wifiID})
    if theUser
      #console.log("setWifiUserStatus: update");
      WifiUsers.update({'userId': userId, 'wifiID':wifiID}, {$set: {status:status, userType:userType, BSSID:bssid, createTime:new Date()}})
      if status is 'online'
        WifiUsers.update({'userId': userId, 'wifiID':wifiID}, {$inc: {visitTimes: 1}})
    else
      userRecord = {
        userId: userId,
        userName: if Meteor.user().profile.nike then Meteor.user().profile.nike else Meteor.user().username,
        userPicture: if Meteor.user().profile.picture then Meteor.user().profile.picture else '/userPicture.png',
        createTime: new Date(),
        wifiID: wifiID,
        BSSID: bssid,
        status: status,
        visitTimes: 1,
        userType: userType
      }
      console.log("setWifiUserStatus: insert");
      WifiUsers.insert(userRecord)

  console.log("UserConnections init");
  UserConnections = new Mongo.Collection("user_status_sessions", {connection: null})
  UserConnections.remove({})

  wifiUsers = WifiUsers.find({}).fetch()
  if wifiUsers.length > 0
      console.log("wifiUsers.length = "+wifiUsers.length)
      for n in [0..wifiUsers.length-1]
        if wifiUsers[n].status is 'online' or wifiUsers[n].userType is 'user'
          WifiUsers.update({_id:wifiUsers[n]._id}, {$set: {status:'offline', userType:'bypasser'}})
  
  addSession = (connection)->
    UserConnections.upsert connection.id,
      $set: {
        ipAddr: connection.clientAddress
        userAgent: connection.httpHeaders['user-agent']
      }
  
  loginSession = (connection, date, userId) ->
    console.log('loginSession: id='+connection.id+', userId='+userId);
    UserConnections.upsert connection.id,
      $set: {
        userId: userId
        loginTime: date
      }

  tryLogoutSession = (connection, date) ->
    return false unless (conn = UserConnections.findOne({
      _id: connection.id
      userId: { $exists: true }
    }))?

  removeSession = (connection, date) ->
    tryLogoutSession(connection, date)
    UserConnections.remove(connection.id)

  Meteor.publish null, ->
    return [] unless @_session?
    unless @userId?
      console.log('publish user left: '+@_session.connectionHandle.id)
      userSession = UserConnections.findOne({_id: @_session.connectionHandle.id})
      if userSession and userSession.wifiID
        setWifiUserStatus(userSession.userId, userSession.wifiID, userSession.BSSID, 'offline')
      removeSession(@_session.connectionHandle, new Date())
    return []

  @updateSession = (userId, wifiID, bssid) ->
    #console.log("updateSession: userId="+userId+", wifiID="+wifiID)
    UserConnections.upsert {userId:userId},
      $set: {
        userId: userId
        wifiID: wifiID
        BSSID: bssid
      }

  Meteor.onConnection((connection)->
    console.log('New connection %s from %s', connection.id, connection.clientAddress);
    addSession(connection)
    connection.onClose ->
      console.log('onClose user left: '+connection.id)
      userSession = UserConnections.findOne({_id: connection.id})
      if userSession and userSession.wifiID
        setWifiUserStatus(userSession.userId, userSession.wifiID, userSession.BSSID, 'offline')
      removeSession(connection, new Date())
  );