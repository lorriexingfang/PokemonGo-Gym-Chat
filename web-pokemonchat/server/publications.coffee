Meteor.startup ()->
  Meteor.publish(
    'chatUsers'
    (id)->
      console.log("this.userId="+this.userId)
      if(this.userId is null)
        return []
      #Meteor.setTimeout ()->
      #  window.updateMyOwnLocationAddress();
      #,60*1000
      this._session.socket.on("close", Meteor.bindEnvironment(()->
          clearNewCommentsMessage(id)
        (e)->
          console.log("close err: "+e)
        )
      )
      ChatUsers.find({userId: this.userId, toUserId:id})
  )

  Meteor.publish(
    'wifi'
    (id)->
      console.log('wifi ' + id)
      Wifis.find({'_id': id})
  )

  Meteor.publish(
    'getWifiInfoBybssid'
    (bssid)->
      if bssid
        wifi = Wifis.findOne({'BSSID': bssid})
        if wifi
          return [Wifis.find({'_id': wifi._id}), WifiPosts.find({wifiID: wifi._id}), WifiUsers.find({wifiID: wifi._id}), ChatUsers.find({userId: this.userId, toUserId: wifi._id})]
        else
          return []
      else
        return []
  )

  Meteor.publish(
    'wifiUsers'
    (id)->
      console.log('wifiUsers'  + id)
      WifiUsers.find({wifiID:id})
  )

  Meteor.publish(
    'wifiPosts'
    (id)->
      console.log('wifiPosts' + id)
      WifiPosts.find({wifiID:id})
  )

  Meteor.publish 'postOne', (id)->
    if id is null or id is undefined or id is ''
      []
    else
      Meteor.publishWithRelations {
        handle: this
        filter: id
        collection: Posts
        mappings: [
          {
            foreign_key: 'userId'
            collection: Meteor.users
            options: {
              fields: {username: 1, 'profile.nike': 1, 'profile.picture': 1}
            }
          }
          {
            foreign_key: 'views.userId'
            collection: Meteor.users
            options: {
              fields: {username: 1, 'profile.nike': 1, 'profile.picture': 1}
            }
          }
          {
            foreign_key: 'replys.userId'
            collection: Meteor.users
            options: {
              fields: {username: 1, 'profile.nike': 1, 'profile.picture': 1}
            }
          }
        ]
      }