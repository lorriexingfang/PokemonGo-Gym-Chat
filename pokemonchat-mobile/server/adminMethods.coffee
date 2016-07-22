#@bishen.org
#2014.12.15 管理员操作方法
# 活动
Meteor.startup ->
    Meteor.methods
        delByUserIds:(ids)->
            if Meteor.user().profile.isAdmin is 1
                for id in ids
                    Meteor.users.update(id,{$set:{'profile.violation':true}})
                1
        unlockByUserIds:(ids)->
            if Meteor.user().profile.isAdmin is 1
                for id in ids
                    Meteor.users.update(id,{$set:{'profile.violation':false}})
                1
        userProFile:(id,field,value)->
            if Meteor.user().profile.isAdmin is 1
                Meteor.users.update id,{$set:{field:value}}
                1
        profile_isBusiness:(id,v)->
            if Meteor.user().profile.isAdmin is 1
                Meteor.users.update id,{$set:{'profile.isBusiness':v}}
                1
        profile_isVip:(id,v)->
            if Meteor.user().profile.isAdmin is 1
                Meteor.users.update id,{$set:{'profile.isVip':v}}
                1
        profile_isAdmin:(id,v)->
            if Meteor.user().profile.isAdmin is 1
                Meteor.users.update id,{$set:{'profile.isAdmin':v}}
                1
        profile_isTestUser:(id,v)->
            if Meteor.user().profile.isAdmin is 1
                Meteor.users.update id,{$set:{'profile.isTestUser':if v is 1 then true else false}}
                1
        activity_add:(activityId,uid,title,subhead,text,photo)->
            if Meteor.user().profile.isAdmin is 1
                us = Meteor.users.findOne(uid)
                if us
                    token = PushToken.find({userId:us._id}).fetch()
                    tokenInfo = if (token.length >=1) then {type:token[0].type,token:token[0].token}  else {}
                    data =
                        type: 'activity'
                        title:title
                        subhead:subhead
                        text: text
                        views:[] #浏览人
                        toJoin:[] #加入的人
                        replys:[] #评论
                        tags:[]
                        token: tokenInfo
                        images: photo
                        userId: uid
                        name: us.username
                        nike: us.profile.nike
                        userPicture: us.profile.picture
                        createdAt: new Date()
                    if activityId is 0
                        Posts.insert data,(error, _id)->
                    else
                        data =
                            title:title
                            subhead:subhead
                            text: text
                            token: tokenInfo
                            images: photo
                            userId: uid
                            name: us.username
                            nike: us.profile.nike
                            userPicture: us.profile.picture
                        Posts.update activityId,{$set:data}
                    10
                else
                    1 # 无此用户
            else
                0 # 无权限添加
        activity_del:(id)->
            if Meteor.user().profile.isAdmin is 1
                Posts.remove({_id:id,type:'activity'})
                1
            else
                0
        updateUserProfileTags:(userId,tags)->
            if Meteor.user().profile.isAdmin is 1
                Meteor.users.update {
                    _id:userId  
                },{
                    $set: {'profile.tags': tags}
                }
                true
            else
                false