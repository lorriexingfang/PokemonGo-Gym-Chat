if Meteor.isServer
  Meteor.startup ()->
    Meteor.methods
      "updatePushToken": (userId, type, token, whichAPP)->
        Meteor.defer ()->
          console.log('updatePushToken')
          # 没有登录
          if userId is null or userId is undefined or this.userId is null
            if PushToken.find({type: type, token: token}).count() <= 0
              PushToken.insert {type: type, token: token}
          #else if userId isnt this.userId
          #  不是当前登录的用户按没有登录处理
          #  if PushToken.find({type: type, token: token}).count() <= 0
          #    PushToken.insert {type: type, token: token}
          else
            # 用户注册过
            if PushToken.find({userId:userId}).count() > 0
              if whichAPP
                PushToken.update {userId: userId}, {$set: {type: type, token: token, whichAPP: whichAPP}}
              else
                PushToken.update {userId: userId}, {$set: {type: type, token: token, whichAPP: 'travelers'}}
            # 已有pushToken
            else if PushToken.find({type: type, token: token}).count() > 0
              if whichAPP
                PushToken.update {type: type, token: token}, {$set: {userId: userId, whichAPP: whichAPP}}
              else
                PushToken.update {type: type, token: token}, {$set: {userId: userId, whichAPP: 'travelers'}}
            else
              if whichAPP
                PushToken.insert {userId: userId, type: type, token: token, whichAPP: whichAPP}
              else
                PushToken.insert {userId: userId, type: type, token: token, whichAPP: 'travelers'}
          
