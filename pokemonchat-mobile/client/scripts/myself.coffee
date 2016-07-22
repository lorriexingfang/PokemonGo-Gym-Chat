#@bishen.org
#2014.11.12
if Meteor.isClient
    loginSuccess = (name, email)->
#        Meteor.subscribe('chats')
#        Meteor.subscribe('chatUsers')
#        Meteor.subscribe('userHomepage_photos',Meteor.userId())
#        Meteor.subscribe('userHomepage_userInfo',Meteor.userId())
#        Meteor.subscribe('userHomepage_posts',Meteor.userId())
#        Meteor.subscribe('userHomepage_photos',Meteor.userId())
#
#        # 处理token
#        registrationID = Session.get("registrationID")
#        registrationType = Session.get("registrationType")
#        updatePushNotificationToken(registrationType,registrationID)
        safeUpdateDeviceWifi()
        window.plugins.jPushPlugin.resumePush()
        Meteor.call 'isLockUser', name,email,(error,result)->
            if result
                PUB.toast '您的帐号被核实有不良信息，已被封号！'
                Meteor.logout (err)->
                    throw err if err
                    PUB.page 'login'

    Session.setDefault 'my_view','my_service'
    Template.dashboard.onRendered ()->
        console.log('Template.dashboard.onRendered')
        if(Meteor.userId() isnt null)
            Session.set('view', 'my_info')
        else if(Meteor.loggingIn())
            Session.set('view', 'login_ing')
        else
            Session.set('view', 'login')
#    Template.dashboard.helpers
#        loggingIn: ()->
#            Meteor.loggingIn()
#    Template.login_ing.rendered=->
#        Template.public_loading_index.__helpers.get('show')('登录中...')
#    Template.login_ing.destroyed=->
#        Template.public_loading_index.__helpers.get('close')()
    Template.my_info.rendered=->
#        if Meteor.user().profile.picture is undefined
#            Meteor.users.update Meteor.userId(),{$set:{'profile.picture':'userPicture.png'}}
        if(Session.equals("display-lang",undefined))
            Session.set('display-lang',getUserLanguage())
    Template.my_info.helpers
        is_anonymous: () ->
            if Meteor.user()? && Meteor.user().profile? && Meteor.user().profile.anonymous?
              return Meteor.user().profile.anonymous
        is_face: ()->
            if(Meteor.user().profile.picture is undefined or Meteor.user().profile.picture is '/userPicture.png' or Meteor.user().profile.picture is 'userPicture.png')
                false
            else
                true
        is_business: ()->
            Meteor.user().profile.isBusiness is 1
        wait_read_count:->
            if Meteor.user() is null
                0
            else
                waitReadCount = 0
                chatUsers = ChatUsers.find({userId: Meteor.userId(), waitReadCount: {$gt: 0}}).fetch()
                for item in chatUsers
                    waitReadCount = waitReadCount + item.waitReadCount
                waitReadCount
        is_wait_read_count: (count)->
            count > 0
        signature:->
            if Meteor.user().profile and Meteor.user().profile.signature then Meteor.user().profile.signature
        myview:->
            Session.get 'my_view'
        manage:->
            Meteor.user().profile and Meteor.user().profile.isAdmin is 1
        is_detailed:->
            Session.get('my_view') is "my_detailed"
        is_partner:->
            Session.get('my_view') is "my_partner"
        is_service:->
            Session.get('my_view') is "my_service"
        is_photos:->
            Session.get('my_view') is "my_photos"
        isEnglish: () ->
            if Session.equals("display-lang",undefined)
              getUserLanguage() is 'en'
            else
              Session.equals("display-lang",'en')
        nike:->
            Meteor.user().profile.nike
    Template.my_info.events
        'click #my_shop':->
            Meteor.call('viewWifiBusiness', Meteor.userId())
            Session.set('online-view', 'wifiOnlineText')
            Session.set('wifiOnlineId', Meteor.userId())
            Session.set('online-return', 'my_info')
            PUB.page("wifiOnline")
        'click #my_detailed':->
            PUB.page 'my_detailed'
        'click #my_business':->
            PUB.page 'my_business'
        'click #my_message_record':->
            PUB.page 'my_service'
        'click #my_blackboard_record':->
            PUB.page 'my_blackboard'
        'click #display_lang': ->
            PUB.page 'display_lang'
        'click #my_about':->
            PUB.page 'about_youzha'
            return
        'click #my_partner_management':->
            PUB.page 'shop_manager'
            return
        'click #my_apply_partner':->
            PUB.page 'apply_partner'
            return
        'click #btn_logout':->
            if Meteor.status().connected isnt true
                PUB.toast '当前为离线状态,请检查网络连接'
                return

            Template.public_loading_index.__helpers.get('show')('正在退出，请稍候...')
            userId = Meteor.userId()
            Meteor.logout (err)->
                if err
                    #console.log err
                    PUB.toast '退出失败，请重试！'
                else
                    window.plugins.jPushPlugin.stopPush()
                    Meteor.setTimeout(
                        ()->
                            Meteor.call('userLogout', userId)
                        4000
                    )
                    Session.set('view', 'dashboard')
                Template.public_loading_index.__helpers.get('close')()
        'click #btn_users':->
            PUB.page('manage_users')
        'click #btn_active':->
            PUB.page('activity_manage')
        'click #my_sign':->

            PUB.page('my_signature')
        'click .my_btns li':(e)->
            $('#'+Session.get('my_view')).attr('class','')
            PUB.page(e.currentTarget.id)
            e.currentTarget.className = 'on'
            return
        'click #my_face':(e)->
            val = e.currentTarget.innerHTML
            uploadFile(
                (result)->
                    if result
                        Meteor.users.update Meteor.userId(),{$set:{'profile.picture':result}}
                1
            )
            return

        # 收件箱 @feiwu
        "click #btn_message":->
            PUB.page("my_message")
#    Template.my_photosPlay.rendered=->
#        $('.swiper-container').css 'height',($(window).height()-50)+'px'
#        $('.swiper-container').css 'width',$(window).width()+'px'
#        new Swiper '.swiper-container',
#            loop:false
#            grabCursor: true
#            createPagination: false
#        return
#    Template.my_photosPlay.helpers
#        images:->
#            Photos.find({'userId':Meteor.userId()}, {sort: {createdAt: -1},limit:100})
#    Template.my_photosPlay.events
#        'click .swiper-container':->
#            Session.set 'myview','my_photos'
#            Session.set 'view','my_info'
        'click .my_info li':(e)->
            PUB.page 'my_'+e.currentTarget.id
            return
    Template.my_photos.helpers
        images:->
            Photos.find({'userId':Meteor.userId()}, {sort: {createdAt: -1},limit:100})
    Template.my_photos.events
        'click .my_photos img':(e)->
            photos = Photos.find({'userId':Meteor.userId()}, {sort: {createdAt: -1},limit:100})
            images = new Array()
            photos.forEach (item)->
                images.push item.imageUrl
            Session.set "images_view_images", images
            Session.set "images_view_images_selected", e.currentTarget.src
            PUB.page 'images_view'
    Template.my_partner.helpers
        partner:->
            Posts.find({'type':'pub_board','userId':Meteor.userId()}, {sort: {createdAt: -1},limit:10})
    Template.my_detailed.helpers
        isBusiness:->
            Meteor.user().profile.isBusiness is 1
        isVip:->
            Meteor.user().profile.isVip is 1

    Template.my_detailed.events
        'click .actions li':(e)->
            PUB.page 'my_'+e.currentTarget.id
            return
        'click #btn_back':->
            PUB.back()
            return
        'click .my_detailed li':(e)->
            if e.currentTarget.id is "province"
                if Meteor.user().profile.isVip is 1
                    window.plugins.toast.showLongBottom '当地人认证后无法修改城市!'
                    return false
            if e.currentTarget.id is 'businessManager'
                #商家文章管理
                PUB.page 'shop_manager'
                return false
            PUB.page 'my_'+e.currentTarget.id
            return
    Template.my_business.helpers
        title:->
            if Meteor.user().profile.isBusiness is 1
                '已认证商家'
            else if Meteor.user().profile.isBusiness is 2
                '请等待认证'
            else
                '未认证商家'
        images:->
            Meteor.user().profile.approves
        wifi_count: ->
          if(Meteor.user().business.wifi is undefined)
            0
          else
            Meteor.user().business.wifi.length

    Template.my_business.events
        'click #btn_back':->
            PUB.back()
        'click #add':(e)->
            imgArr = if Meteor.user().profile.approves then Meteor.user().profile.approves else []
            uploadFile (result)->
                if result
#                    dd = document.createElement 'dd'
#                    dd.style.backgroundImage = 'url('+result+')'
#                    e.currentTarget.parentNode.insertBefore dd,e.currentTarget
                    imgArr.push {img:result,createdAt:new Date()}
                    Meteor.users.update Meteor.userId(),{$set:{'profile.approves':imgArr}}
                else
                    window.plugins.toast.showLongBottom '上传失败!'
                return
            return
        'click #deleteImage': (e)->
          img = $(e.currentTarget).parent().find("img").attr("src")
          images = if Meteor.user().profile.approves then Meteor.user().profile.approves else []

          if images.length > 0
            PUB.confirm(
              "确定要删除此图片吗？"
              ()->
                for i in [0..images.length-1]
                  if images[i].img is img
                    images.splice(i, 1)
                    break

                Meteor.users.update Meteor.userId(),{$set:{'profile.approves':images}}
            )


        'click #btn_save':->
            business = Meteor.user().profile.business
            tel = Meteor.user().profile.tel
            address = Meteor.user().profile.address

            location = Session.get('location')
            if location
              geometry = {type:"Point",coordinates:[location.longitude,location.latitude]}
            else
              geometry= {type:"Point",coordinates:[0,0]}

            if isNullOrEmpty(business, tel, address, Meteor.user().profile.approves)
#                window.plugins.toast.showLongBottom('请完整填写表单！')
#                Meteor.call 'toast','请完整填写表单! ',(e)->
                PUB.toast '请完整填写表单'
            else
                Meteor.users.update Meteor.userId(),{$set:{'profile.isBusiness':2}}
                Meteor.users.update Meteor.userId(),{$set:{'profile.businessLocation':geometry}}
#                window.plugins.toast.showLongBottom '已提交资料，请等待审核!'
#                Meteor.call 'toast','已提交资料，请等待审核! ',(e)->
                PUB.toast '已提交资料，请等待审核!'
                PUB.page 'my_info'
        'click .set-up li':(e)->
            if (e.currentTarget.id is null or e.currentTarget.id is '')
                return
            else if(e.currentTarget.id is 'titleImage')
                uploadFile(
                    (result)->
                        if result
                            Meteor.users.update Meteor.userId(),{$set:{'business.titleImage':result}}
                    1
                )
            else
                Session.set 'referrer','my_business'
                PUB.page 'edit_'+e.currentTarget.id
                return
    Template.my_vip.helpers
        title:->
            if Meteor.user().profile.isVip is 1
                '已认证当地人'
            else if Meteor.user().profile.isVip is 2
                '请等待认证'
            else
                '未认证当地人'
        images:->
            Meteor.user().profile.approves
    Template.my_vip.events
        'click #btn_back':->
            PUB.back()
        'click #add':(e)->
            imgArr = if Meteor.user().profile.approves then Meteor.user().profile.approves else []
            uploadFile (result)->
                if result
#                    dd = document.createElement 'dd'
#                    dd.style.backgroundImage = 'url('+result+')'
#                    e.currentTarget.parentNode.insertBefore dd,e.currentTarget
                    imgArr.push {img:result,createdAt:new Date()}
                    Meteor.users.update Meteor.userId(),{$set:{'profile.approves':imgArr}}
                else
                    window.plugins.toast.showLongBottom '上传失败!'
                return
            return
        'click .btn_save':->
            if isNullOrEmpty(Meteor.user().profile.identity, Meteor.user().profile.tel, Meteor.user().profile.approves)
              PUB.toast '请完整填写表单！'
              return

            Meteor.users.update Meteor.userId(),{$set:{'profile.isVip':2}}
            window.plugins.toast.showLongBottom '已提交资料，请等待审核!'
            Session.set 'vuew','my_info'
        'click .my_detailed li':(e)->
            Session.set 'referrer','my_vip'
            PUB.page 'edit_'+e.currentTarget.id
            return
    Template.sendRestPWD.events
        'click #btn_back':->
            Session.set 'view','login'
            return
        'click #btn_login':->
            PUB.page 'login'
            return
        'submit #form-forgot':(e,t)->
            e.preventDefault()
            t.find('#sub-forgot').disabled = true
            t.find('#sub-forgot').value = '正在提交信息...'
            email  = t.find("#email").value.toLowerCase()
            myRegExp = /[a-z0-9-]{1,30}@[a-z0-9-]{1,65}.[a-z]{2,6}/ ;
            if email is ''
                PUB.toast '请输入注册邮箱！'
                t.find('#sub-forgot').disabled = false
                t.find('#sub-forgot').value = '找回密码'
            else if myRegExp.test(email) is false
                PUB.toast '你的邮箱有误！'
                t.find('#sub-forgot').disabled = false
                t.find('#sub-forgot').value = '找回密码'
            else
                Meteor.call 'findUserByEamil',email,(e,r)->
                    console.info e
                    console.info r
                    if r isnt undefined
                        Meteor.call 'sendResetPasswordEmail',r._id,r.emails[0].address,(e,r)->
                            if e is undefined
                                Session.set 'view','login'
                                PUB.toast '邮件已发，请登录您的邮箱重置密码。'
                            else
                                console.info e
                                PUB.toast '发邮件遇到问题'
                        return
                    else
                        PUB.toast '此邮箱未注册！'
                        t.find('#sub-forgot').disabled = false
                        t.find('#sub-forgot').value = '找回密码'
                        return
                return
    Template.login_ing.rendered=->
      Template.public_loading_index.__helpers.get('close')()
    Template.login.helpers
        is_android: ()->
            return if Meteor.isCordova then device.platform is 'Android' else false
#        test: ()->
#            result = new Array(100)
#            setInterval = Meteor.setInterval(
#                ()->
#                    console.log(result.length)
#                    if(result.length > 0)
#                        result.pop()
#                        if(Meteor.userId() is null)
#                            Meteor.loginWithPassword('jingbin1988@xd.com', '123456')
#                        else if(Meteor.user().profile.nike is undefined)
#                            Meteor.clearInterval(setInterval)
#                        else
#                            Meteor.logout()
#                    else
#                        Meteor.logout()
#                        Meteor.clearInterval(setInterval)
#                500
#            )
    Template.login.events
        'click #anony-login': ()->
            $('.login-box').hide()
            $('.anonymous-box').show()
        'click .reg-tips': ()->
            Session.set('view', 'deal_page')
            Session.set('dealFromPage', 'anonymous')
        'click #anony-login-ok': ()->
            AnonymousLogin()
        'click .fbLogIn': (e,t)->
            if Meteor.status().connected isnt true
                PUB.toast '当前为离线状态,请检查网络连接'
                return
            Meteor.loginWithFacebook (err, result)->
                if err
                    PUB.toast 'Fail to log in to Facebook.'
                    return console.log err
                else
                    if Meteor.user().profile.new is undefined or Meteor.user().profile.new is true
                        console.log '------------- no facebook log in before----------'
                        Meteor.users.update({_id: Meteor.userId()},{$set:{"profile.new":true}})
                    if Session.get("login_return_view") is undefined or Session.get("login_return_view") is ''
                        Session.set 'myview','my_detailed'
                        PUB.page 'my_info'
                    else
                        PUB.page Session.get("login_return_view")
                    
        'click .loginWithWeixin': ->
            if Meteor.status().connected isnt true
                PUB.toast '当前为离线状态,请检查网络连接'
                return

            Template.public_loading_index.__helpers.get('show')('登录中，请稍候...')
            Meteor.setTimeout(
                ()->
                    Template.public_loading_index.__helpers.get('close')()
                1000
            )
            Meteor.loginWithWeixin (err, result)->
                Template.public_loading_index.__helpers.get('close')()

                if err
                    console.log err
                else
                    #setTimeout(loginSuccess, 1000)
                    if Session.get("login_return_view") is undefined or Session.get("login_return_view") is ''
                        Session.set 'myview','my_detailed'
                        PUB.page 'my_info'
                    else
                        PUB.page Session.get("login_return_view")
#        'click .fa-qq': ->
#            Meteor.loginWithQQ (err, res)->
#                if err isnt undefined
#                    console.log 'sucess ' + res
#                else
#                    console.log 'login failed ' + err
#        'click .fa-weibo': ->
#            Meteor.loginWithWeibo (err, res)->
#                if err isnt undefined
#                    console.log 'sucess ' + res
#                else
#                    console.log 'login failed ' + err
        'click #forgotPWD':->
            PUB.page 'sendRestPWD'
            return
        'click #btn_registered':->
            PUB.page 'registered'
            return
        'submit #form-login':(e,t)->
            e.preventDefault()
            if Meteor.status().connected isnt true
                PUB.toast '当前为离线状态,请检查网络连接'
                return false
            t.find('#sub-login').disabled = true
            t.find('#sub-login').value = '正在登录...'
            name = t.find('#name').value.toLowerCase().replace('@','#')
            email = t.find('#name').value.toLowerCase()
            pass = t.find('#pass').value
            if name is '' or pass is ''
                PUB.toast '邮箱或密码不能为空!'
                t.find('#sub-login').disabled = false
                t.find('#sub-login').value = '登录'
                return false

            Template.public_loading_index.__helpers.get('show')('登录中，请稍候...')
            Meteor.loginWithPassword name, pass,(err)->
                if err
                    #console.log err1
                    PUB.toast '帐号或密码有误！'
                    t.find('#sub-login').disabled = false
                    t.find('#sub-login').value = '登录'
                else if Session.get("login_return_view") is undefined or Session.get("login_return_view") is ''
                    setTimeout(loginSuccess(name, email), 1000)
                    Session.set 'myview','my_detailed'
                    Session.set 'channel', 'dashboard'
                    PUB.page 'my_info'
                else
                    setTimeout(loginSuccess(name, email), 1000)
                    PUB.page Session.get("login_return_view")
                Template.public_loading_index.__helpers.get('close')()
            return false

    Template.manage_users.rendered=->
        Session.set 'selUserIds',','
        Session.set 'uquery',Meteor.users.find({"username":{"$ne":"cctv"}},{limit:10,sort: {'profile.createdAt': -1}}).fetch()
    Template.manage_users.helpers
        users:->
            Session.get 'uquery'
        be:(v)->
            v is 1 or v is true
        admin:(v)->
            v is 2
    Template.manage_users.events
        'click .search-btn': (e)->
            $("#search-btn").html '搜索中...'
            key = $("#usearch").val()
            Meteor.subscribe 'seachUsers', key, (error)->
              k = new RegExp(key)
              result = Meteor.users.find({$or: [{username: k},{'profile.nike': k}]}, {limit:10, sort: {'profile.createdAt': -1}}).fetch()
              list = new Array()
              for item in result
                if item.username.toString().indexOf("cctv") < 0
                  list.push item
              Session.set 'uquery', list
              if list.length <= 0
                  PUB.toast '没有此用户！'
              $("#search-btn").html '搜索'

        'click #btn_back':->
            PUB.back()
        'click #delUsers':->
            if Session.get('selUserIds') is ','
                alert '请选择要处理的用户！'
            else
                ids = Session.get('selUserIds').toString()
                ids = ids.substring(1,ids.length-1)
#                Meteor.subscribe 'delByUserIds',ids.split(','),(r)->
                Meteor.call 'delByUserIds',ids.split(','),(error, result)->
                    if error
                        PUB.toast('操作失败！')
                    else if result is 1
                        PUB.toast('已经处理')
                    else
                        PUB.toast('处理失败！')
            return
        'contextmenu .users dl':(e)->
            if e.currentTarget.className is 'on'
                Session.set 'selUserIds',Session.get('selUserIds').replace(','+e.currentTarget.id+',',',')
                e.currentTarget.className = ''
            else
                Session.set 'selUserIds',Session.get('selUserIds')+e.currentTarget.id+','
                e.currentTarget.className = 'on'
            false
        'click #qtype li':(e)->
            $('#qtype li').attr 'class',''
            e.currentTarget.className = 'on'
            switch Number e.currentTarget.id
                when 1 then Session.set 'uquery',Meteor.users.find({"profile.isBusiness":1,"username":{"$ne":"cctv"}},{limit:100,sort: {'profile.createdAt': -1}}).fetch()
                when 2 then Session.set 'uquery',Meteor.users.find({"profile.isVip":1,"username":{"$ne":"cctv"}},{limit:100,sort: {'profile.createdAt': -1}}).fetch()
                when 3 then Session.set 'uquery',Meteor.users.find({"profile.isBusiness":2,"username":{"$ne":"cctv"}},{limit:100,sort: {'profile.createdAt': -1}}).fetch()
                when 4 then Session.set 'uquery',Meteor.users.find({"profile.isVip":2,"username":{"$ne":"cctv"}},{limit:100,sort: {'profile.createdAt': -1}}).fetch()
                when 5 then Session.set 'uquery',Meteor.users.find({"profile.report":true,"username":{"$ne":"cctv"}},{limit:100,sort: {'profile.createdAt': -1}}).fetch()
                else Session.set 'uquery',Meteor.users.find({"username":{"$ne":"cctv"}},{limit:100,sort: {'profile.createdAt': -1}}).fetch()
            return
        'click .users dt':(e)->
#            Meteor.call 'user_home',e.currentTarget.id,(e)->
            PUB.user_home(e.currentTarget.id)
            return
        'click .users dd':(e)->
            id= e.currentTarget.id
            f = e.currentTarget.getAttribute 'type'
            if f is "more"
                Session.set "manage_users_more_id", id
                PUB.page "manage_users_more"
            else
                v = Number e.currentTarget.getAttribute 'value'
                n = if f is 'isAdmin' then 2 else 1
                n = if v is 0 then n else 0
                e.currentTarget.className = if v is 0 then 'fa fa-circle' else 'fa fa-circle-o'
                e.currentTarget.setAttribute 'value',n
                callback = (error, result)->
                    if error
                        PUB.toast '操作失败'
                    else if result is 1
                        PUB.toast '操作成功'
                    else
                        PUB.toast '操作失败'

                if f is 'isAdmin'
                    Meteor.call 'profile_isAdmin',id,n,callback
                else if f is 'isBusiness'
                    Meteor.call 'profile_isBusiness',id,n,callback
                else if f is 'isVip'
                    Meteor.call 'profile_isVip',id,n,callback
                else if f is 'isTestUser'
                    Meteor.call 'profile_isTestUser',id,n,callback
    #            Meteor.subscribe 'profile.'+f,id,n,(r)->
                return
#        'keyup #usearch':(e)->
#            k = new RegExp(e.currentTarget.value)
#            result = Meteor.users.find({username: k}, {limit:100, sort: {'profile.createdAt': -1}}).fetch()
#            list = new Array()
#            for item in result
#                if item.username.toString().indexOf("cctv") < 0
#                    list.push item
#            Session.set 'uquery', list

    Template.manage_users_more.rendered=->
        #Meteor.subscribe 'userinfo', Session.get("manage_users_more_id")
        #Session.set "manage_users_more_user_tags", Meteor.users.findOne({_id:Session.get("manage_users_more_id")}).profile.tags
        user = serverPushedUserInfo.findOne({_id: Session.get("manage_users_more_id")})

        if user is undefined or user is null
            Meteor.subscribe 'userinfo', Session.get("manage_users_more_id")
            user = Meteor.users.findOne({_id:Session.get("manage_users_more_id")})

        Session.set "manage_users_more_user_tags", user.profile.tags

    Template.manage_users_more.helpers
        is_tagA:->
            tags = Session.get("manage_users_more_user_tags")
            tags.filter (item, i)->
                return item is "旅游达人"
        is_tagB:->
            tags = Session.get("manage_users_more_user_tags")
            tags.filter (item, i)->
                return item is "客栈"
        is_tagC:->
            tags = Session.get("manage_users_more_user_tags")
            tags.filter (item, i)->
                return item is "吃货"
        is_tagD:->
            tags = Session.get("manage_users_more_user_tags")
            tags.filter (item, i)->
                return item is "俱乐部"
    Template.manage_users_more.events
        "click #btn_back":->
            PUB.back()
        "submit .user_tags_form":(e)->
            tags = []
            if e.target.tagA.checked
                tags.push "旅游达人"
            if e.target.tagB.checked
                tags.push "客栈"
            if e.target.tagC.checked
                tags.push "吃货"
            if e.target.tagD.checked
                tags.push "俱乐部"
            Meteor.call "updateUserProfileTags", Session.get("manage_users_more_id"), tags, (error,result)->
                if error or result is false
                    PUB.toast '操作失败'
                else
                    PUB.toast '操作成功'
                    Session.set "manage_users_more_id", undefined
                    Session.set "manage_users_more_user_tags", undefined
                    PUB.back()
            false
      Template.edit_wifi.helpers
          wifi: ()->
              Meteor.user().business.wifi || []
          add_wifi: (callback)->
              if(!testDeviceConnectedWifi())
                  PUB.toast('当前没有连接到WIFI！')
              else
                  navigator.wifi.getConnectedWifiInfo(
                      (wifi)->
                          wifi.BSSID = wifi.BSSID.toLowerCase()
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
                          console.log(wifi)

                          exist = false
                          if(Meteor.user().business.wifi is undefined or Meteor.user().business.wifi.length <= 0)
                              #
                          else
                              for item in Meteor.user().business.wifi
                                  if(item.BSSID is wifi.BSSID)
                                      exist = true
                                      break

                          if(exist)
                              PUB.toast('您已经绑定过此wifi了，请绑定一个之前未被绑定的WiFi！')
                          else
                              showLoading()
                              Meteor.call "isBSSIDRegistered", wifi.BSSID, (error, result) ->
                                closeLoading()
                                if error
                                  PUB.toast('绑定失败，请重试！');
                                else if result is true
                                  PUB.toast('当前WiFi已被别的商家绑定，请绑定一个之前未被绑定的WiFi！')
                                else
                                  Meteor.users.update(
                                    {_id: Meteor.userId()}
                                    {$push: {'business.wifi': wifi}}
                                    (err, number)->
                                      if(err or number <= 0)
                                          PUB.toast('绑定失败，请重试！');
                                      else
                                          callback()
                                    )
                      ()->
                          PUB.toast('获取Wi-Fi信息失败！');
                  )
      Template.edit_wifi.events
          'click .leftButton':->
            window.page.back()
          'click .my_detailed li': (e)->
              wifi = Meteor.user().business.wifi || []
              newWifi = []
              for item in wifi
                  if(item.BSSID isnt e.currentTarget.id)
                      newWifi.push(item)
              PUB.confirm(
                  '你确定要删除吗？'
                  ()->
                      Meteor.users.update(
                          {_id: Meteor.userId()}
                          {$set: {'business.wifi': newWifi}}
                          (err, number)->
                              if(err or number <= 0)
                                  PUB.toast('删除失败！')
                      )
              )
          'click .btn_save': ()->
              Template.edit_wifi.__helpers.get('add_wifi')(
                  ()->
                      PUB.toast('绑定成功！')
              )
      Template.edit_typeImage.helpers
          type: (val)->
              return Meteor.user().business.typeImage is val
      Template.edit_typeImage.events
          "click #btn_back":->
              PUB.back()
          'click li': (e)->
              Meteor.users.update Meteor.userId(),{$set:{'business.typeImage': '/wifi/'+ e.currentTarget.id + '.png'}}
              PUB.back()
      
      Template.display_lang.helpers
          isEnglish: ()->
              if Session.equals("display-lang",undefined)
                getUserLanguage() is 'en'
              else
                Session.equals("display-lang",'en')
      Template.display_lang.events
        'click #btn_back':->
              PUB.back()
        'click #english': ()->
              Session.set('display-lang','en') 
              Cookies.set('display-lang','en',360)
              TAPi18n.setLanguage("en")
              PUB.back()
        'click #chinese': ()->
              Session.set('display-lang','zh')
              Cookies.set('display-lang','zh',360)
              TAPi18n.setLanguage("zh")
              PUB.back()
          