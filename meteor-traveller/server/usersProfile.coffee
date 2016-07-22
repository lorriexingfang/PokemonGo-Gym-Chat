#@bishen.org
#2014.11.25 修改用户属性
Meteor.publish 'delByUserIds',(ids)->
    if Meteor.user().profile.isAdmin is 1
        for id in ids
            Meteor.users.update(id,{$set:{'profile.violation':true}})
Meteor.publish 'unlockByUserIds',(ids)->
    if Meteor.user().profile.isAdmin is 1
        for id in ids
            Meteor.users.update(id,{$set:{'profile.violation':false}})
        return
Meteor.publish 'profile.isBusiness',(id,v)->
    if Meteor.user().profile.isAdmin is 1
        Meteor.users.update id,{$set:{'profile.isBusiness':v}}
        return
Meteor.publish 'profile.isVip',(id,v)->
    if Meteor.user().profile.isAdmin is 1
        Meteor.users.update id,{$set:{'profile.isVip':v}}
        return
Meteor.publish 'profile.isAdmin',(id,v)->
    if Meteor.user().profile.isAdmin is 1
        Meteor.users.update id,{$set:{'profile.isAdmin':v}}
        return
Meteor.publish 'ready',(v)->
    console.log 'waiting page changed : '+v
Meteor.publish 'sendSMS',(m,n)->
    parm = 
        account:'cf_xundong_km'
        password:'D07EA2047EC93E772CF183BC02E4A7B7'
        mobile:m
        content:'您的验证码是：'+n+'。请不要把验证码泄露给其他人。'
    Meteor.http.post "http://106.ihuyi.cn/webservice/sms.php?method=Submit",
        {params:parm},
        (error, result)->
            if result.statusCode is 200
                Sms.insert({mobile:m,text:parm.content,createdAt: new Date()})
                console.log '成功发送短信'+m
            else
                console.log '短信发送失败！'
    []