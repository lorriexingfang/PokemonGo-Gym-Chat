Meteor.startup ()->
  mongoPosts.before.insert (userId, doc)->
    if doc.type is 'pub_board' and doc.text.length >= "#免费客栈#".length
      text = doc.text
      if text.substring(text.length - "#免费客栈#".length) is '#免费客栈#'
        doc.events = [{eventNo: '2015-01'}]
        doc.text = text.substring(0, text.length - "#免费客栈#".length)
        console.log doc.text

    update_post_tags(doc._id)

    # 发送搭伙小喇叭
    if(doc.type is 'pub_board')
      Meteor.defer ()->
        # 给附近的用户推送搭伙消息
        user_bell = Meteor.users.findOne({username: TRAVELLER_BELL})
        location = doc.location.coordinates
        distance = 60/111.12
        try
          cursor = Meteor.users.find({'profile.lastLocation.coordinates': {$near:location,$maxDistance:distance}})

          cursor.forEach(
            (user)->
              try
                if(user._id isnt userId)
                  console.log("向附近的用户'#{user._id}'发送搭伙消息")
                  mongoChats.insert(
                    {
                      userId: user_bell._id
                      userName: user_bell.profile.nike
                      userPicture: user_bell.profile.picture
                      toUserId: user._id
                      toUserName: if user.profile is undefined or user.profile.nike is undefined then user.username else user.profile.nike
                      toUserPicture: if user.profile.picture then user.profile.picture else '/userPicture.png'
                      text: "#{doc.nike}发布了新搭伙：#{doc.text}"
                      isRead: false
                      readTime: undefined
                      createdAt: new Date()
                      msgType: 'system'
                      isPushNotification: true
                      postId: doc._id #record post id to navigate from chat to post
                    }
                  )
              catch err
                console.log(err)
          )
        catch err
          console.log(err)
          console.log('请使用“db.users.ensureIndex({"profile.location.coordinates": "2d"})”为users的location建立索引')
          console.log('请使用“db.users.ensureIndex({"profile.lastLocation.coordinates": "2d"})”为users的location建立索引')

    # 给管理员发送搭伙信息
    Meteor.defer ()->
      console.log "A new post release."

      user = Meteor.users.findOne(userId)
      if user.profile.isTestUser and user.profile.isTestUser is true
        return

      if doc.type is 'local_service' or doc.type is 'pub_board'
        # cctv
        toUser = Meteor.users.findOne('SgYefkCBo7kE4FEXT')
        if doc.type is 'local_service'
          text = "#{doc.name}发布了当地服务：<a href='http://121.42.32.154:443/post/#{doc._id}' target='_blank'>http://121.42.32.154:443/post/#{doc._id}</a>"
        else if doc.type is 'pub_board'
          text = "#{doc.nike}发布了搭伙：<a href='http://121.42.32.154:443/post/#{doc._id}' target='_blank'>http://121.42.32.154:443/post/#{doc._id}</a>"

        user_helper = Meteor.users.findOne({'username': TRAVELLER_HELPER})
        mongoChats.insert(
          {
            userId: user_helper._id
            userName: user_helper.profile.nike
            userPicture: user_helper.profile.picture
            toUserId: toUser._id
            toUserName: toUser.profile.nike
            toUserPicture: toUser.profile.picture
            text: text
            isRead: false
            readTime: undefined
            createdAt: new Date()
            msgType: 'system'
            postId: doc._id #record post id to navigate from chat to post
          }
        )

  # 入口： posts的before.insert
  # 功能： 处理游记及搭伙的tag
  #       1、游记从标题或内容中提取tags表中的tag
  #       2、如果当前tag是城市则还提取所有的省份，如昆明则最终的tags为昆明、云南
  # 注意： 如果在before.update中有业务逻辑要处理，必需要小心，因为本方法中调用了posts的update
  # @feiwu
  update_post_tags = (id)->
    Meteor.defer ()->
      doc = mongoPosts.findOne(id)
      if doc.type is 'notes' and doc.tags.length > 0
#            mongoTags.find({}).forEach (t)->
#              if (doc.title + doc.content + doc.html).indexOf(t.tag) isnt -1
#                hasTag = false
#                for i in [0..doc.tags.length - 1]
#                  if doc.tags[i] is t.tag
#                    hasTag = true
#                    break
#                if !hasTag
#                  doc.tags.push t.tag

        # 处理省份
        waitAddTags = new Array()
        for i in [0..doc.tags.length - 1]
          for ii in [0..citys.length - 1]
            if citys[ii].name is doc.tags[i]
              for iii in [0..province.length - 1]
                if province[iii].ProID is citys[ii].ProID
                  waitAddTags.push province[iii].name
                  break

        if waitAddTags.length > 0
          for a in [0..waitAddTags.length - 1]
            hasPush = false
            for b in [0..doc.tags.length - 1]
              if doc.tags[b] is waitAddTags[a]
                hasPush = true
                break
            if !hasPush
              doc.tags.push waitAddTags[a]

        #console.log "waitAddTags:#{waitAddTags}"
        #console.log "update post is tag(#{doc.tags})."
        mongoPosts.update doc._id, {$set: {tags: doc.tags}}, (err, rows)->
          if err
            console.log err
          else if rows <= 0
            console.log "update failed(#{doc._id})."
          else
            console.log "update post(#{doc._id}) is tag(#{doc.tags})."

      else if doc.type is 'pub_board' and doc.tags.length > 0
        # 处理省份
        tags = mongoTags.find({}).fetch()
        waitAddTags = new Array()
        for i in [0..doc.tags.length - 1]
          for ii in [0..citys.length - 1]
            # 当前tag是城市
            if citys[ii].name is doc.tags[i].tag
              for iiii in [0..tags.length - 1]
                if tags[iiii].tag is doc.tags[i].tag
                  for iii in [0..province.length - 1]
                    if province[iii].ProID is citys[ii].ProID
                      waitAddTags.push {id: tags[iiii]._id, tag: province[iii].name}
                      break
                  break

        if waitAddTags.length > 0
          for a in [0..waitAddTags.length - 1]
            hasPush = false
            for b in [0..doc.tags.length - 1]
              if doc.tags[b].tag is waitAddTags[a].tag
                hasPush = true
                break
            if !hasPush
              doc.tags.push waitAddTags[a]

        #console.log "waitAddTags:#{waitAddTags}"
        #console.log "update post is tag(#{doc.tags})."
        mongoPosts.update doc._id, {$set: {tags: doc.tags}}, (err, rows)->
          if err
            console.log err
          else if rows <= 0
            console.log "update failed(#{doc._id})."
          else
            console.log "update post(#{doc._id}) is tag(#{doc.tags})."

  mongoPosts.before.remove (userId, doc)->
    Meteor.defer ()->
      if(doc.type is 'ad' and doc.subtitle isnt undefined)
        Meteor.users.update(
          {_id: userId}
          {
            $pull: {'business.reports': {'articleId': doc._id}}
          }
        )
  mongoPosts.before.update (userId, doc, fieldNames, modifier, options)->
    # 发送搭伙消息
    Meteor.defer ()->
      if(doc.type is 'ad' and doc.subtitle isnt undefined)
        Meteor.users.update(
          {_id: userId, 'business.reports.articleId': doc._id}
          {
            $set: {
              'business.reports.$.text': doc.subtitle
              'business.reports.$.title': doc.title
              'business.reports.$.images': doc.images
            }
          }
        )
      
      if(`fieldNames == 'replys'` and modifier.$push isnt undefined and doc.type is 'pub_board')
        # 自己发的评论
        if doc.userId is modifier.$push.replys.userId and modifier.$push.replys.toUserId is undefined
          return

        user_message = Meteor.users.findOne({username: TRAVELLER_MESSAGE})
        user_post = Meteor.users.findOne({_id: doc.userId})
        user = Meteor.users.findOne(userId)
        text = "#{if user.profile.nike then user.profile.nike else user.username}回复了您的搭伙:#{modifier.$push.replys.comment},搭伙内容：#{doc.text}"

        #当原作者回复B的评论时，不发消息给原作者
        if doc.userId isnt modifier.$push.replys.userId
          mongoChats.insert(
            {
            userId: user_message._id
            userName: user_message.profile.nike
            userPicture: user_message.profile.picture
            toUserId: user_post._id
            toUserName: if user_post.profile.nike then user_post.profile.nike else user_post.username
            toUserPicture: if user_post.profile.picture then user_post.profile.picture else '/userPicture.png'
            text: text
            isRead: false
            readTime: undefined
            createdAt: new Date()
            msgType: 'system'
            }
          )

        if modifier.$push.replys.toUserId isnt undefined and modifier.$push.replys.toUserId isnt user_post._id
          replyToUserID = Meteor.users.findOne(modifier.$push.replys.toUserId)
          mongoChats.insert(
            {
            userId: user_message._id
            userName: user_message.profile.nike
            userPicture: user_message.profile.picture
            toUserId: replyToUserID._id
            toUserName: if replyToUserID.profile.nike then replyToUserID.profile.nike else replyToUserID.username
            toUserPicture: if replyToUserID.profile.picture then replyToUserID.profile.picture else '/userPicture.png'
            text: text
            isRead: false
            readTime: undefined
            createdAt: new Date()
            msgType: 'system'
            }
          )
    true

  Wifis.before.remove (userId, doc)->
    Meteor.defer ()->
        ChatUsers.remove(
          {'toUserId': doc._id, "msgTypeEx":"wifiboard"},
        )
