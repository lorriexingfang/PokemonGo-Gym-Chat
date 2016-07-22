if Meteor.isServer
  Meteor.startup ()->
    Meteor.users.before.update (userId, doc, fieldNames, modifier, options)->
      #console.log(modifier)
      if(`fieldNames == 'profile'`)
        modifier.$set = modifier.$set || {}

        Meteor.defer ()->
          # 修改昵称
          nike = modifier.$set["profile.nike"]
          if(nike isnt undefined)
            console.log "user '" + userId + "' update nike."
            # 更新搭话
            #mongoChats.update {userId: userId}, {$set: {userName: nike}}
            #mongoChats.update {toUserId: userId}, {$set: {toUserName: nike}}
            mongoChatUsers.update {userId: userId, msgTypeEx: {$ne: 'business'}}, {$set: {userName: nike}}, {multi: true}
            mongoChatUsers.update {toUserId: userId, msgTypeEx: {$ne: 'business'}}, {$set: {toUserName: nike}}, {multi: true}

            # 更新 Posts
            mongoPosts.update {userId: userId}, {$set: {name: nike, nike: nike}}, {multi: true}
            postCursor = mongoPosts.find {'replys.userId': userId}
            postCursor.forEach(
              (post)->
                replys = post.replys
                if replys.length > 0
                  for i in [0..replys.length - 1]
                    if replys[i].userId is userId
                      replys[i].username = nike
                  mongoPosts.update {_id: post._id}, {$set: {replys: replys}}
            )

          # 修改头像
          picture = modifier.$set["profile.picture"]
          if(picture isnt undefined)
            console.log "user '" + userId + "' update picture."
            # 更新搭话
            #mongoChats.update {userId: userId}, {$set: {userPicture: picture}}
            #mongoChats.update {toUserId: userId}, {$set: {toUserPicture: picture}}
            mongoChatUsers.update {userId: userId, msgTypeEx: {$ne: 'business'}}, {$set: {userPicture: picture}}, {multi: true}
            mongoChatUsers.update {toUserId: userId, msgTypeEx: {$ne: 'business'}}, {$set: {toUserPicture: picture}}, {multi: true}

            # 更新 Posts
            mongoPosts.update {userId: userId}, {$set: {userPicture: picture}}, {multi: true}
            postCursor = mongoPosts.find({'replys.userId': userId})
            postCursor.forEach(
              (post)->
                replys = post.replys
                if replys.length > 0
                  for i in [0..replys.length - 1]
                    if replys[i].userId is userId
                      replys[i].userPicture = picture
                  mongoPosts.update {_id: post._id}, {$set: {replys: replys}}
            )

          # 商家修改名称
          business = modifier.$set["profile.business"]
          if(business isnt undefined and doc.profile.isBusiness is 1)
            console.log "user '" + userId + "' update business."
            # 更新搭话
            #mongoChats.update {userId: userId}, {$set: {userName: nike}}
            #mongoChats.update {toUserId: userId}, {$set: {toUserName: nike}}
            mongoChatUsers.update {userId: userId, msgTypeEx: 'business'}, {$set: {userName: business}}, {multi: true}
            mongoChatUsers.update {toUserId: userId, msgTypeEx: 'business'}, {$set: {toUserName: business}}, {multi: true}

          # 商家修改标题图
          titleImage = modifier.$set["business.titleImage"]
          if(titleImage isnt undefined and doc.profile.isBusiness is 1)
            console.log "user '" + userId + "' update titleImage."
            # 更新搭话
            #mongoChats.update {userId: userId}, {$set: {userPicture: picture}}
            #mongoChats.update {toUserId: userId}, {$set: {toUserPicture: picture}}
            mongoChatUsers.update {userId: userId, msgTypeEx: 'business'}, {$set: {userPicture: titleImage}}, {multi: true}
            mongoChatUsers.update {toUserId: userId, msgTypeEx: 'business'}, {$set: {toUserPicture: titleImage}}, {multi: true}

