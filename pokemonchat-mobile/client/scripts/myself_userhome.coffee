#@bishen.org
#2014.11.29 某用户空间
if Meteor.isClient
    Session.setDefault 'myview','home_service'
    Template.home_info.rendered=->
        #if Session.get('userId') is undefined and Meteor.users.findOne(Session.get('userId')) is undefined
        #if Session.get('userId') is undefined and serverPushedUserInfo.findOne(Session.get('userId')) is undefined
        #    alert '没有此用户！'
        #    false
        if Session.get('userId') is undefined or (serverPushedUserInfo.findOne(Session.get('userId')) is undefined and Meteor.users.findOne(Session.get('userId')) is undefined)
            alert '没有此用户！'
            false
    Template.home_info.helpers 
        user:->
            #Meteor.users.findOne(Session.get('userId'))
            #serverPushedUserInfo.findOne(Session.get('userId'))
            user = serverPushedUserInfo.findOne(Session.get('userId'))
            if user is undefined or user is null
                user = Meteor.users.findOne(Session.get('userId'))
            user            
        signature:->
            #if Meteor.users.findOne(Session.get('userId')) and Meteor.users.findOne(Session.get('userId')).profile.signature then Meteor.users.findOne(Session.get('userId')).profile.signature else '没有个性签名'
            user = serverPushedUserInfo.findOne(Session.get('userId'))
            if user is undefined or user is null
                user = Meteor.users.findOne(Session.get('userId'))
            if user and user.profile and user.profile.signature then user.profile.signature else '没有个性签名'
        myview:->
            Session.get 'myview'
        is_detailed:->
            Session.get('myview') is "home_detailed"
        is_partner:->
            Session.get('myview') is "home_partner"
        is_service:->
            Session.get('myview') is "home_service"
        is_photos:->
            Session.get('myview') is "home_photos"
	
    Template.home_info.events 
        'click #btn_back':->
#            Meteor.call 'back',(e)->
            #Session.set 'view',Session.get 'homereferrer'
            PUB.back()
        'click .my_btns li':(e)->
            $('#'+Session.get('myview')).attr('class','')
            Session.set 'myview',e.currentTarget.id
            e.currentTarget.className = 'on'
  # 举报
        'click #btn_report':->
            Meteor.users.update Meteor.userId(),{$set:{'profile.report':true}}
            PUB.toast('感谢您帮助我们清理不良信息！');
		# 搭话
        "click #btn_message":->
            if Meteor.user() is null
                window.plugins.toast.showLongBottom '请登录后搭话!'
                return
            if Meteor.userId() is Session.get("userId")
                window.plugins.toast.showLongBottom "不能和自己搭话！"
                return

            Session.set "chat_to_userId", Session.get("userId")
#            Meteor.call 'page','chat_home',(e)->
            Session.set('chat_return_view', Session.get('view'))
            Session.set('view', 'chat_home')
            #PUB.page 'chat_home', {return_view: Session.get("view")}
            Meteor.setTimeout ->
                document.body.scrollTop = document.body.scrollHeight
                300
    Template.home_photos.helpers 
        images:->
            Photos.find({'userId':Session.get('userId')}, {sort: {createdAt: -1},limit:100})
    Template.home_photos.events 
        'click img':(e)->
            photos = Photos.find({'userId':Session.get('userId')}, {sort: {createdAt: -1},limit:100})
            images = new Array()
            photos.forEach (item)->
                images.push item.imageUrl
            Session.set "images_view_images", images
            Session.set "images_view_images_selected", e.currentTarget.src
#            Meteor.call 'page','images_view',(e)->
            PUB.page 'images_view'
    Template.home_partner.partner=->
        Posts.find({'type':'pub_board','userId':Session.get('userId')}, {sort: {createdAt: -1},limit:10})
    Template.home_service.helpers
        service:->
            Posts.find({'type':{$in:['local_service','pub_board']},'userId':Session.get('userId')}, {sort: {createdAt: -1},limit:20})
        is_service:(type)->
            if type is "local_service"
                return true
            false
    Template.home_detailed.events 
        'click #check_vip':(e)->
            e.currentTarget.value = '通过当地人认证！'
            Meteor.subscribe 'profile.isVip',Session.get('userId'),1,(r)->
        'click #check_business':(e)->
            e.currentTarget.value = '通过商家认证！'
            Meteor.subscribe 'profile.isBusiness',Session.get('userId'),1,(r)->
        'click #out_vip':(e)->
            e.currentTarget.value = '已取消当地人认证！'
            Meteor.subscribe 'profile.isVip',Session.get('userId'),0,(r)->
        'click #out_business':(e)->
            e.currentTarget.value = '已取消商家认证！'
            Meteor.subscribe 'profile.isBusiness',Session.get('userId'),0,(r)->
    Template.home_detailed.helpers 
        user:->
            #Meteor.subscribe "userinfo", Session.get('userId')
            #Meteor.users.findOne(Session.get('userId'))
            user = serverPushedUserInfo.findOne({_id: Session.get('userId')})

            if user is undefined or user is null
                Meteor.subscribe "userinfo", Session.get('userId')
                user = Meteor.users.findOne(Session.get('userId'))
            user
        isBusiness1:->
            try
                #Meteor.users.findOne(Session.get('userId')).profile.isBusiness is 1
                user = serverPushedUserInfo.findOne(Session.get('userId'))
                if user is undefined or user is null
                    user = Meteor.users.findOne(Session.get('userId'))
                user.profile.isBusiness is 1
            catch
                false
        isBusiness2:->
            try
                #Meteor.users.findOne(Session.get('userId')).profile.isBusiness is 2
                user = serverPushedUserInfo.findOne(Session.get('userId'))
                if user is undefined or user is null
                    user = Meteor.users.findOne(Session.get('userId'))
                user.profile.isBusiness is 2
            catch
                false
        isVip1:->
            try
                #Meteor.users.findOne(Session.get('userId')).profile.isVip is 1
                user = serverPushedUserInfo.findOne(Session.get('userId'))
                if user is undefined or user is null
                    user = Meteor.users.findOne(Session.get('userId'))
                user.profile.isVip is 1
            catch
                false
        isVip2:->
            try
                #Meteor.users.findOne(Session.get('userId')).profile.isVip is 2
                user = serverPushedUserInfo.findOne(Session.get('userId'))
                if user is undefined or user is null
                    user = Meteor.users.findOne(Session.get('userId'))
                user.profile.isVip is 2
            catch
                false
        isAdmin:->
            try
                Meteor.user().profile.isAdmin is 1 or Meteor.user().profile.isAdmin is 2
            catch
                false
        isMale:->
            try
                #Meteor.users.findOne(Session.get('userId')).profile.sex is '男'
                user = serverPushedUserInfo.findOne(Session.get('userId'))
                if user is undefined or user is null
                    user = Meteor.users.findOne(Session.get('userId'))
                user.profile.sex is '男'
            catch
                false
