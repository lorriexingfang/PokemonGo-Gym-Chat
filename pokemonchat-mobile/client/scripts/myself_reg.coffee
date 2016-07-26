#@bishen.org
#2014.11.28
if Meteor.isClient
    Template.registered_one.rendered=->
        rndCode =->
            rnd=""
            for i in [0..3]
                rnd += Math.floor(Math.random()*10)
            rnd
        code = rndCode()
        Session.set 'code',code
        #Session.set 'smsResult','432423'
    Template.registered_one.helpers
        smsMsg:->
            Session.get 'smsMsg'
        smsCode:->
            Session.get 'smsCode'
    Template.registered_one.events
        'click #btn_back':->
            Session.set 'view','login'
            return
        'click #btn_login':->
            Session.set 'view','login'
            return
        'keyup #name':(e)->
            e.currentTarget.value = e.currentTarget.value.replace(/[^\d]/g,'')
            return
        'submit #form-registered':(e,t)->
            e.preventDefault()
            Session.set 'smsCode',''
            Session.set 'smsMsg',''
            t.find('#sub-registered').disabled = true
            t.find('#sub-registered').value = '正在发送...'
            names = t.find('#name').value.replace(/[^\d]/g,'')
            if names is ''
#                Meteor.call 'toast','请输入手机号码！',(e)->
                PUB.toast '请输入手机号码！'
                t.find('#sub-registered').disabled = false
                t.find('#sub-registered').value = '获取验证码'
            else if names.length isnt 11
#                Meteor.call 'toast','手机号码不正确！',(e)->
                PUB.toast '手机号码不正确！'
                t.find('#sub-registered').disabled = false
                t.find('#sub-registered').value = '获取验证码'
            else
                #判断重复注册
                _user  = Meteor.users.findOne({'username':names})
                if _user isnt undefined
#                    Meteor.call 'toast','手机号码已被使用! ',(e)->
                    PUB.toast '手机号码已被使用！'
                    t.find('#sub-registered').disabled = false
                    t.find('#sub-registered').value = '获取验证码'
                    return false
                Session.set 'userName',names
                Meteor.call 'sendSMS',names,Session.get('code'),(e,r)->
                    console.log r
                    if r.result is 'ok'
                        oParser = new DOMParser()
                        xmlDoc = oParser.parseFromString r.xml,"text/xml"
                        code = xmlDoc.getElementsByTagName("code")[0].firstChild.nodeValue
                        msg = xmlDoc.getElementsByTagName("msg")[0].firstChild.nodeValue
                        if code is '2'
                            Session.set 'smsCode',''
                            Session.set 'smsMsg',''
                            Session.set 'view','registered'
                        else
                            Session.set 'smsCode',code
                            Session.set 'smsMsg',msg
                            t.find('#sub-registered').disabled = false
                            t.find('#sub-registered').value = '获取验证码'
                    else
                        Session.set 'smsMsg','请检测网络'
                        t.find('#sub-registered').disabled = false
                        t.find('#sub-registered').value = '获取验证码'
            false
    Template.deal_page.events
        'click #btn_back':->
            origin = Session.get('dealFromPage')
            if origin is 'registered'
                Session.set 'view','registered'
            else
                Session.set 'view','login'
                Meteor.setTimeout(
                    ()->
                        $('#anony-login').trigger('click')
                    50
                )
            return
    Template.registered.rendered=->
        cachedRegEmail = Session.get('cachedRegEmail')
        if (cachedRegEmail)
            this.$('#names').val(cachedRegEmail)
        cachedRegNike = Session.get('cachedRegNike')
        if (cachedRegNike)
            this.$('#nike').val(cachedRegNike)
        cachedRegPass = Session.get('cachedRegPass')
        if (cachedRegPass)
            this.$('#pass').val(cachedRegPass)
        cachedRegPass2 = Session.get('cachedRegPass2')
        if (cachedRegPass2)
            this.$('#pass2').val(cachedRegPass2)
    Template.registered.events
        'click #btn_back':->
            PUB.back()
            return
        'keydown #nike': (event, tpl) ->
            if event.keyCode is 8
                return true
            target = event.target
            count = target.value.replace(/[^\x00-\xff]/g,"**").length
            count < 16
        'change #nike, keydown #nike, blur #nike': (event, tpl) ->
            target = event.target
            value = target.value
            count = value.replace(/[^\x00-\xff]/g,"**").length
            while count > 16
                value = value.substring(0, value.length-1)
                count = value.replace(/[^\x00-\xff]/g,"**").length
            target.value = value
        'blur #names':(e)->
            if (e.target.value)
                Session.set('cachedRegEmail', e.target.value)
            return
        'blur #nike':(e)->
            if (e.target.value)
                Session.set('cachedRegNike', e.target.value)
            return
        'blur #pass':(e)->
            if (e.target.value)
                Session.set('cachedRegPass', e.target.value)
            return
        'blur #pass2':(e)->
            if (e.target.value)
                Session.set('cachedRegPass2', e.target.value)
            return
        'click #btn_back':->
            Session.set 'view','login'
            return
        'click #btn_login':->
            Session.set 'view','login'
            return
#        'keyup #names':(e)->
#            e.currentTarget.value = e.currentTarget.value.replace(/[^\d]/g,'')
#            return
        'click #see_deal':->
            Session.set 'view','deal_page'
            Session.set('dealFromPage', 'registered')
            return
        'click .loginSelType li':(e)->
            $('.loginSelType li').attr 'class','fa fa-circle-o'
            e.currentTarget.className = 'fa fa-check-circle-o'
        'submit #form-registered':(e,t)->
            e.preventDefault()
            t.find('#sub-registered').disabled = true
            t.find('#sub-registered').value = '正在提交信息...'
#           code = t.find('#code').value.replace(/[^\d]/g,'')
            names = t.find('#names').value.toLowerCase().replace('@','#')
            email = t.find('#names').value.toLowerCase()
            Session.set 'userName',names
            nike  = t.find('#nike').value
            pass1 = t.find('#pass').value
            pass2 = t.find('#pass2').value
            myRegExp = /[a-z0-9-]{1,30}#[a-z0-9-]{1,65}.[a-z]{2,6}/ ;
            if names is ''
#                Meteor.call 'toast','Please enter your email address!',(e)->
                PUB.toast 'Please enter your email address!'
                t.find('#sub-registered').disabled = false
                t.find('#sub-registered').value = 'Sign up'
            else if myRegExp.test(names) is false
#                Meteor.call 'toast','Invalid eamil address!',(e)->
                PUB.toast 'Invalid eamil address!'
                t.find('#sub-registered').disabled = false
                t.find('#sub-registered').value = 'Sign up'
#            else if code isnt Session.get('code')
#                Meteor.call 'toast','验证码不正确！',(e)->
#                t.find('#sub-registered').disabled = false
#                t.find('#sub-registered').value = 'Sign up'
            else if nike is ''
#                Meteor.call 'toast','Please enter your nickname!',(e)->
                PUB.toast 'Please enter your nickname!'
                t.find('#sub-registered').disabled = false
                t.find('#sub-registered').value = 'Sign up'
            else if pass1.length < 6
#                Meteor.call 'toast','Password should contain at least 6 words!',(e)->
                PUB.toast 'Password should contain at least 6 words!'
                t.find('#sub-registered').disabled = false
                t.find('#sub-registered').value = 'Sign up'
            else if pass1 isnt pass2
#                Meteor.call 'toast','Passwords don't match!',(e)->
                PUB.toast 'Passwords don\'t match!'
                t.find('#sub-registered').disabled = false
                t.find('#sub-registered').value = 'Sign up'
            else if t.find('#deal_check').checked is false
                PUB.toast '请同意小店公告服务告知！'
                t.find('#sub-registered').disabled = false
                t.find('#sub-registered').value = 'Sign up'
            else
#                由于本地的数据不一定是最新的，以下判断没有实际价值
#                #判断是否重复邮箱注册
#                console.log 'username:'+names+';email:'+email
#                Meteor.subscribe 'loginUserInfo', names, email
#                _user  = Meteor.users.findOne({$or:[{'username':names},{'emails.address':email}]})
#                if _user isnt undefined
##                    Meteor.call 'toast','This email has been used! ',(e)->
#                    PUB.toast '邮箱已被使用！'
#                    t.find('#sub-registered').disabled = false
#                    t.find('#sub-registered').value = 'Sign up'
#                    return false
#                #判断是否重复昵称
#                _user  = Meteor.users.findOne({'profile.nike':nike})
#                if _user isnt undefined
##                    Meteor.call 'toast','昵称已被使用! ',(e)->
#                    PUB.toast '昵称已被使用！'
#                    t.find('#sub-registered').disabled = false
#                    t.find('#sub-registered').value = 'Sign up'
#                    return false
                try
                    uuid = device.uuid
                catch err
                    uuid = ''
#                #判断设备号是否重复，一台设备只允许注册2个号码。
#                if uuid isnt ''
#                    _count  = Meteor.users.find({'profile.uuid':uuid}).count()
#                    if _count >= 2
##                        Meteor.call 'toast','此设备已经注册超过两个用户',(e)->
#                        PUB.toast '此设备已经注册超过两个用户！'
#                        t.find('#sub-registered').disabled = false
#                        t.find('#sub-registered').value = 'Sign up'
#                        return false

                Meteor.call 'isDeviceIdUsed',uuid,(error,result)->
                    if result
                        PUB.toast '您的手机已注册2个帐号！'
                        t.find('#sub-registered').disabled = false
                        t.find('#sub-registered').value = 'Sign up'
                    else
                        Meteor.call 'isUserNikeUsed',nike,(error,result)->
                            if result
                                PUB.toast '昵称已经存在！'
                                t.find('#sub-registered').disabled = false
                                t.find('#sub-registered').value = 'Sign up'
                            else
                                location = Session.get('location')
                                geometry = null
                                if location
                                    geometry = {type:"Point",coordinates:[location.longitude,location.latitude]}
                                else
                                    geometry = {type:"Point",coordinates:[0,0]}
                                Accounts.createUser
                                    username:Session.get('userName') #防止以前的数据有重复
                                    email:email
                                    password:pass1
                                    profile:
                                        uuid:uuid
                                        nike:nike
                                        picture:'userPicture.png'
                                        createdAt:new Date()
                                        isVip:0
                                        isBusiness:0
                                        isAdmin:0
                                        location: geometry
                                    (err)->
                                        if err
                                            console.log err
                #                            Meteor.call 'toast','注册失败！',(e)->
                                            PUB.toast '注册失败，邮箱或昵称可能已经存在！'
                                            t.find('#sub-registered').disabled = false
                                            t.find('#sub-registered').value = 'Sign up'
                                        else
#                                            Meteor.subscribe('chats')
#                                            Meteor.subscribe('chatUsers')
#                                            Meteor.subscribe('userHomepage_photos',Meteor.userId())
#                                            Meteor.subscribe('userHomepage_userInfo',Meteor.userId())
#                                            Meteor.subscribe('userHomepage_posts',Meteor.userId())
#                                            Meteor.subscribe('userHomepage_photos',Meteor.userId())
#
#                                            # 处理token
#                                            registrationID = Session.get("registrationID")
#                                            registrationType = Session.get("registrationType")
#                                            if registrationID isnt undefined and registrationType isnt undefined
#                                                setTimeout(
#                                                    ()->
#                                                        updatePushNotificationToken(registrationType,registrationID)
#                                                    100
#                                                  )

                                            if Session.get("login_return_view") is undefined or Session.get("login_return_view") is ''
                                                Session.set 'view','my_info'
                                            else
                                                Session.set 'view', Session.get("login_return_view")
                                            updateDeviceWifi()
                                            Session.set('cachedRegEmail', '')
                                            Session.set('cachedRegNike', '')
                                            Session.set('cachedRegPass', '')
                                            Session.set('cachedRegPass2', '')
                                        return
            false
