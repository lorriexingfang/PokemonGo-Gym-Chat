# Space 4
if Meteor.isClient
    Template.blackboard_main.helpers
        city:->
            return if Session.get("city") is undefined then '昆明市' else  Session.get("city")
        is_local_service:->
            if Session.get('postType') is "local_service"
                true
            else
                false
        board_title:->
            post_type = Session.get 'postType'
            if post_type is 'pub_board'
                '当地'
            else if post_type is 'local_service'
                '当地'
        admin:(v)->
            v is 1
        user:->
            Meteor.user()
    Template.blackboard_main_post.helpers
        posts:->
            #当地服务分组
            group = Session.get "local_service_group_id"

            geolocation = Session.get 'location'
            lnglat = [0,0]
            lnglat = [geolocation.longitude,geolocation.latitude] if geolocation

            view = Session.get("view")
            post_type = Session.get 'postType'
            switch view
                when "shop" # 商户->服务
                    userId = Session.get "shopId"
                    return Posts.find {type: "local_service",userId: userId},{sort:{createdAt: -1},limit:10}
                when "home_info" # 个人主页->喳喳
                    userId = Session.get("userId")
                    return Posts.find {'type':{$in: ['local_service', 'pub_board']},userId: userId},{sort:{createdAt: -1},limit:10}
                when "dashboard" # 我的主页->服务
                    return Posts.find {'type':{$in: ['local_service', 'pub_board']},userId: Meteor.userId()},{sort:{createdAt: -1},limit:10}
                when "partner_finding" # 搭伙->最新活动
                    return Posts.find {
                        type: 'local_service'
                        location:
                            $near:
                                $geometry:
                                    type: "Point"
                                    coordinates: lnglat
                                $maxDistance: 2000000   #meters
                    }, {
                        sort: {createdAt: -1}
                        limit:50
                    }
                else
                    if Session.get('city') is '附近'
                        if Session.get("location_city") isnt undefined
                            return Posts.find {
                                type: 'local_service'
                                city: Session.get("location_city")
                                location:
                                    $near:
                                        $geometry:
                                            type: "Point"
                                            coordinates: lnglat
                                        $maxDistance: 2000000   #meters
                            }, {
                                sort: {createdAt: -1}
                                limit:50
                            }
                        else
                            return Posts.find {
                                type: 'local_service'
                                location:
                                    $near:
                                        $geometry:
                                            type: "Point"
                                            coordinates: lnglat
                                        $maxDistance: 2000000   #meters
                            }, {
                                sort: {createdAt: -1}
                                limit:50
                            }
                    else
                        return Posts.find {type: 'local_service',city: Session.get('city')},{sort:{createdAt: -1}}

    Template.blackboard_post.events
        'click .reportNumber': (e)->
            Session.set "cancelBubble", true
            Session.set 'reportPostId',e.currentTarget.id
            PUB.page("reason")
            Meteor.setTimeout ->
                Session.set "cancelBubble", false
                300
        "click .delete": (e)->
            Session.set "cancelBubble", true
            if confirm("你确定要删除吗？")
                Meteor.call "removePost", e.currentTarget.id, ()->
            Meteor.setTimeout ->
                Session.set "cancelBubble", false
                300
        "click .faceimg": (e)->
            Session.set "cancelBubble", true
            userId = e.currentTarget.id
            Session.set "myview", "home_detailed"
            PUB.user_home(userId)
            Meteor.setTimeout ->
                Session.set "cancelBubble", false
                300
        "click .nickname": (e)->
            Session.set "cancelBubble", true
            userId = e.currentTarget.id
            Session.set "myview", "home_detailed"
            PUB.user_home(userId)
            Meteor.setTimeout ->
                Session.set "cancelBubble", false
                300
        "click .photo img": (e)->
            Session.set "cancelBubble", true
            post = Posts.findOne({_id:e.currentTarget.parentNode.id})
            images = new Array()
            post.images.forEach (item)->
                images.push item.url
            Session.set "images_view_images", images
            Session.set "images_view_images_selected", e.currentTarget.src
            PUB.page("images_view")
            Meteor.setTimeout ->
                Session.set "cancelBubble", false
                300
        "click .btn_detail": (event)->
            if Session.get("cancelBubble")
                return
            post_id = event.currentTarget.id
            console.log ("view is blackboard_detail, current target id is " + post_id)
            Session.set "blackboard_post_id", post_id
            PUB.page("blackboard_detail")
    Template.blackboard_post.helpers
        get_username: (userId)->
            user = serverPushedUserInfo.findOne({_id:userId})
            if user is undefined or user is null
                user = Meteor.users.findOne({_id:userId})
            if user.profile.nike is undefined or user.profile.nike is ""
                return user.username
            user.profile.nike
        get_userpic: (userId)->
            user = serverPushedUserInfo.findOne({_id:userId})
            if user is undefined or user is null
                user = Meteor.users.findOne({_id:userId})            
            user.profile.picture
        get_usertags: (userId)->
            user = serverPushedUserInfo.findOne({_id:userId})
            if user is undefined or user is null
                user = Meteor.users.findOne({_id:userId})            
            if user.profile.tags is undefined
                return []
            user.profile.tags

        get_uservip: (userId)->
            user = serverPushedUserInfo.findOne({_id:userId})
            if user is undefined or user is null
                user = Meteor.users.findOne({_id:userId})            
            try
                user.profile.isVip is 1
            catch
                false
        is_admin: (userId)->
            if Meteor.user() and Meteor.user().profile.isAdmin is 1
                return true
            false
        time_diff: (created)->
            now = new Date();
            GetTime0(now - created);
        show_good: (good)->
            if good then good else 0
        replys_count: (replys)->
            if replys then replys.length else 0
        is_undefined: (picture)->
            if picture == "" or picture == undefined
                true
            else
                false
        is_show_vip: (isVip)->
            if Session.get("view") is "localservice_user_detail"
                false
            else
                isVip is 1
    Template.blackboard_main.events
        "click .button_right": (event)->
            if Meteor.user() is null
                window.PUB.toast '请登录后发布!'
                return
            if !Meteor.user().profile.isVip
                window.PUB.toast '你还没有认证当地人，无法发布!'
                return
            if Meteor.user().profile.city is undefined or Meteor.user().profile.city is ""
                window.PUB.toast '会员资料没有选择城市!'
                return
            Session.set "upload_images",[]
            PUB.page("blackboard_add")
        "click .button_left": (event)->
            PUB.page("city")
        'click .btn_report':->
            Session.set 'rview','partnerReport'
            PUB.page("reportList")
    Template.blackboard_detail.helpers
        detail_title: ->
            post_type = Session.get 'postType'
            if post_type is 'pub_board'
                '当地'
            else if post_type is 'local_service'
                '当地'
    Template.display_blackboard_post_detail.helpers
        get_username: (userId)->
            user = serverPushedUserInfo.findOne({_id:userId})
            if user is undefined or user is null
                user = Meteor.users.findOne({_id:userId})            
            if user.profile.nike is undefined or user.profile.nike is ""
                return user.username
            user.profile.nike
        get_userpic: (userId)->
            #user = Meteor.users.findOne({_id:userId})
            user = serverPushedUserInfo.findOne({_id:userId})
            if user is undefined or user is null
                user = Meteor.users.findOne({_id:userId})            
            user.profile.picture
        get_uservip: (userId)->
            user = serverPushedUserInfo.findOne({_id:userId})
            if user is undefined or user is null
                user = Meteor.users.findOne({_id:userId})            
            try
                user.profile.isVip is 1
            catch
                false
        post:->
            Posts.findOne {_id: Session.get("blackboard_post_id")}
        time_diff: (created)->
            now = new Date();
            GetTime0(now - created);
        show_good: (good)->
            if good then good else 0
        replys_count: (replys)->
            if replys then replys.length else 0
        is_vip: (vip)->
            vip is 1
        get_usertags: (userId)->
            user = serverPushedUserInfo.findOne({_id:userId})
            if user is undefined or user is null
                user = Meteor.users.findOne({_id:userId})            
            if user.profile.tags is undefined
                return []
            user.profile.tags
    Template.display_blackboard_post_detail.events
        "click .faceimg": (e)->
            Session.set "myview", "home_detailed"
            PUB.user_home(e.currentTarget.id)
        "click .nickname": (e)->
            Session.set "myview", "home_detailed"
            PUB.user_home(e.currentTarget.id)
        "click .photo img": (e)->
            Session.set "cancelBubble", true
            post = Posts.findOne({_id:e.currentTarget.id})
            images = new Array()
            post.images.forEach (item)->
                images.push item.url
            Session.set "images_view_images", images
            Session.set "images_view_images_selected", e.currentTarget.src
            PUB.page("images_view")
            Meteor.setTimeout ->
                Session.set "cancelBubble", false
                300
        "click .report": (e)->
            Session.set 'reportPostId',e.currentTarget.id
            PUB.page("report")
#        "click .good": (event)->
#            Posts.update {
#                _id: Session.get("blackboard_post_id")
#            }, {
#                $inc: {
#                    good: 1
#                }
#            }
    Template.blackboard_detail.events
        "click .button_left": (event) ->
#            PUB.back()
            window.page.back()
    Template.blackboard_add.rendered=->
        Template.public_upload_index.__helpers.get('reset')()
        text = $(".dropdown-menu li:first").text()
        $(".dropdown-toggle").html(text+"\r\n<span class='caret'></span>")
        $("#group").val($(".dropdown-menu li:first").attr("id"))

        Session.set "userAddress", Meteor.user().profile.city
        geoc = new BMap.Geocoder()
        point = new BMap.Point(Session.get('location').longitude,Session.get('location').latitude)
        geoc.getLocation point,(rs)->
            if rs and rs.addressComponents
                addComp = rs.addressComponents
                if addComp.city and addComp.city isnt ''
                    Session.set("userAddress",addComp.province+' '+addComp.city+' '+addComp.district) #+' '+addComp.street)
            else
                requestUrl = "http://maps.googleapis.com/maps/api/geocode/json?latlng="+Session.get('location').latitude+','+Session.get('location').longitude+'&sensor=false'
                Meteor.http.call "GET",requestUrl,(error,result)->
                    if result.statusCode is 200
                        results = result.content.results
                        Session.set("userAddress",JSON.stringify(result))
                    return
            return
        return
    Template.blackboard_add.events
        "click .button_left": (event)->
#            PUB.back()
            window.page.back()
        "click .button_right": (event)->
            $("#new-post-on-blackboard").submit()
        "click .dropdown-menu li":  (e)->
            text = $("#"+e.currentTarget.id).text()
            $(".dropdown-toggle").html(text+"\r\n<span class='caret'></span>")
            $("#group").val(e.currentTarget.id)
        "submit .new-post-on-blackboard": (event)->
            # This function is called when the new task form is submitted
            if Meteor.user() is null
                window.PUB.toast '请登录后发布!'
            else if Meteor.user().profile.isVip != 1
                window.PUB.toast '你还没有认证当地人，无法发布!'
            else if Meteor.user().profile.city == undefined
                window.PUB.toast '会员资料没有选择城市!'
            else
                text = event.target.comment.value
                if text is ""
                    window.PUB.toast "内容不能为空"
                    return false

                userAddress = event.target.userAddress.value
                #group = event.target.group.value
                upload_images = Template.public_upload_index.__helpers.get('images')()
                console.log('postType is ' + Session.get('postType') + 'Adding new post: ' + text + ' upload_images is ' + upload_images)
                picture = ''
                if Meteor.user().profile and Meteor.user().profile.picture
                    picture = Meteor.user().profile.picture
                registrationID = Session.get("registrationID")
                registrationType = Session.get("registrationType")
                tokenInfo = {type:registrationType,token:registrationID}
                #console.log ' token is ' + registrationID +' type ' + registrationType
                location = Session.get 'location'
                if location
                    geometry = {type:"Point",coordinates:[location.longitude,location.latitude]}
                else
                    geometry= {type:"Point",coordinates:[0,0]}
                try
                    postId = undefined
                    Posts.insert {
                        type: Session.get 'postType'
                        text: text
                        #group: group
                        good: 0
                        images: upload_images
                        userId: Meteor.user()._id
                        name: if Meteor.user().profile.nike is undefined or Meteor.user().profile.nike is "" then Meteor.user().username else Meteor.user().profile.nike
                        userIsVip: Meteor.user().profile.isVip
                        userPicture: picture
                        city: Meteor.user().profile.city
                        userAddress: userAddress
                        token: tokenInfo
                        location: geometry
                        createdAt: new Date() #current time
                    }, (error, _id)->
                        console.log "Posts insert _id is " + _id
                        for item in upload_images
                            Photos.insert {
                                userId: Meteor.userId()
                                createAt: new Date()
                                postId: _id
                                imageUrl: item.url
                            }
                catch error
                    console.log error
                Template.public_upload_index.__helpers.get('reset')()
                PUB.back()
            false
    Template.blackboard_add.helpers
        postGroup:->
            postGroup
        is_admin:->
            if Meteor.user() and Meteor.user().profile.isAdmin is 1
                return true
            false
        city: ->
            Session.get("city")
        address:->
            Session.get("userAddress")
        add_title: ->
            post_type = Session.get 'postType'
            if post_type is 'pub_board'
                '写黑板'
            else if post_type is 'local_service'
                '添加当地服务'
    Template.reply_blackboard_list.helpers
        get_usernameEx: (userId)->
            user = serverPushedUserInfo.findOne({_id:userId})
            if user is undefined or user is null
                user = Meteor.users.findOne({_id:userId})            
            if user.profile.nike is undefined or user.profile.nike is ""
                return user.username
            user.profile.nike
        get_userpic: (userId)->
            user = serverPushedUserInfo.findOne({_id:userId})
            if user is undefined or user is null
                user = Meteor.users.findOne({_id:userId})            
            user.profile.picture
        get_uservip: (userId)->
            user = serverPushedUserInfo.findOne({_id:userId})
            if user is undefined or user is null
                user = Meteor.users.findOne({_id:userId})            
            user.profile.isVip is 1
        is_reply:(reply)->
            if reply.toUserId is undefined or reply.toUserId is ""
                return false

            true
        get_username:(reply)->
            #Meteor.subscribe 'userinfo', reply.toUserId
            #user = Meteor.users.findOne({_id: reply.toUserId})
            user = serverPushedUserInfo.findOne({_id: reply.toUserId})

            if user is undefined or user is null
                Meteor.subscribe 'userinfo', reply.toUserId
                user = Meteor.users.findOne({_id:reply.toUserId})

            if user.profile.nike is undefined or user.profile.nike is ""
                user.username
            else
                user.profile.nike
        is_admin:->
            if Meteor.user() and Meteor.user().profile.isAdmin is 1
                return true
            false
        replys:->
            getPostReply(Session.get("blackboard_post_id"))
#            Posts.findOne({_id: Session.get("blackboard_post_id")}).replys.sort (a, b)->
#                if a.createdAt > b.createdAt
#                    -1
#                else if a.createdAt < b.createdAt
#                    1
#                else
#                    0
        is_login_user: (userName)->
            if Meteor.user()  and (Meteor.user().username is userName)
                true
            else
                false
        time_diff: (time)->
            now = new Date()
            showTime = GetTime0(now - time)
            if showTime == "0秒前"
                "刚刚"
            else
                showTime
        is_show_reply: (reply)->
            # 非私聊信息
            if reply.toUserId is undefined
                return true
            # 我发及发给我的
            if reply.userId is Meteor.userId() or reply.toUserId is Meteor.userId()
                return true
            false
        # TODO:清除时间相同的项，需要后期重新使用其它方法
        clear_equal_time: ->
            Meteor.setTimeout ->
                prevNode = null
                $("#remark li.time").each (i)->
                    if i == 0
                        prevNode = $(this)
                    else
                        if prevNode.html() == $(this).html()
                            $(this).hide()
                        else
                           prevNode = $(this)
                300
            "" #不返回値
    Template.reply_blackboard_list.events
        "click .delete": (e)->
            if e.currentTarget.id is "" or e.currentTarget.id is undefined
                alert "此条评论无法删除！"
                return
            if confirm("你确定要删除吗？")
                Meteor.call "removePostReply",Session.get("blackboard_post_id") , e.currentTarget.id, ()->
        "click .faceimg": (e)->
            Session.set "myview", "home_detailed"
            PUB.user_home(e.currentTarget.id)
            e.stopPropagation();
        "click .name": (e)->
            Session.set "myview", "home_detailed"
            PUB.user_home(e.currentTarget.id)
            e.stopPropagation();
        "click li": (e)->
            if Meteor.user() is null
                window.PUB.toast '请登录后评论!'
                return
            if Meteor.userId() is e.currentTarget.id
                window.PUB.toast '不能回复自己!'
                return

            Session.set "blackborad_reply_to_userId", undefined
            Session.set "blackborad_footbar_view", "blackboard_footbar_reply"
            Meteor.setTimeout ->
                #user = Meteor.users.findOne({_id: e.currentTarget.id})
                user = serverPushedUserInfo.findOne({_id: e.currentTarget.id})

                if user is undefined or user is null
                    user = Meteor.users.findOne({_id: e.currentTarget.id})

                Session.set "blackborad_reply_to_userId", e.currentTarget.id
                if user.profile.nike is undefined or user.profile.nike is ""
                    #$("#comment").attr("placeholder", "@" + user.username)
                    $(".say_guide").html("@#{user.username}")
                else
                    #$("#comment").attr("placeholder", "@" + user.profile.nike)
                    $(".say_guide").html("@#{user.profile.nike}")
                300
    Template.editor.events
        "click .fa-photo": (event)->
            $("#fileUpload_window").toggle()
            $("#emoji").hide()
        "click .fa-camera": (event)->
            return
        "click .fa-smile-o": (event)->
            $("#fileUpload_window").hide()
            $("#emoji").toggle()
        "click .fa-weibo": (event)->
            $(event.target).toggleClass("disable")
        "click .fa-tencent-weibo": (event)->
            $(event.target).toggleClass("disable")
        "click .fa-twitter": (event)->
            $(event.target).toggleClass("disable")
    Template.emoji.events
        "click .emoji_icon": (event)->
            emoji = $(event.currentTarget).attr "tag"
            $("#editor_textarea").insertContent emoji
    Template.my_service_main.helpers
        service:->
            Posts.find({'type':{$in: ['local_service', 'pub_board']},'userId':Meteor.userId()}, {sort: {createdAt: -1},limit:10})
    Template.my_service.events
        "click #back_btn":->
            window.page.back()
    Template.service_list.helpers
        is_my: (obj)->
            obj.userId is Meteor.userId()
        get_username: (userId)->
            #user = Meteor.users.findOne({_id:userId})
            user = serverPushedUserInfo.findOne({_id:userId})  
            if user is undefined or user is null
                user = Meteor.users.findOne({_id: userId})                       
            if user.profile.nike is undefined or user.profile.nike is ""
                return user.username
            user.profile.nike
        get_userpic: (userId)->
            #user = Meteor.users.findOne({_id:userId})
            user = serverPushedUserInfo.findOne({_id:userId}) 
            if user is undefined or user is null
                user = Meteor.users.findOne({_id: userId})              
            user.profile.picture
        get_uservip: (userId)->
            #user = Meteor.users.findOne({_id:userId})
            user = serverPushedUserInfo.findOne({_id:userId}) 
            if user is undefined or user is null
                user = Meteor.users.findOne({_id: userId})              
            user.profile.isVip is 1
        time_diff: (created)->
            GetTime0(new Date() - created)
        format_day:(day,n)->
            today = new Date(Math.abs(new Date(day)) + (n * 86400000))
            day+' ~ '+today.getFullYear()+"-"+(today.getMonth()+1)+"-"+today.getDate()
        views_count:(v)->
            if v then v else 0
        replys_count:(r)->
            if r then r.length else 0
        get_face:(uid)->
            #if Meteor.users.findOne(uid).profile.picture then Meteor.users.findOne(uid).profile.picture else 'userPicture.png'
            user = serverPushedUserInfo.findOne(uid)

            if user is undefined or user is null
                user = Meteor.users.findOne({_id: uid})  

            if user and user.profile and user.profile.picture then user.profile.picture else 'userPicture.png'
        is_partner: (type)->
            type is 'pub_board'
        is_title_null:(title)->
            if title == undefined or title == ''
                true
            else
                false
    Template.service_list.events
        "click .delete": (e)->
            e.stopPropagation()
            PUB.confirm("你确定要删除吗？", ()->
                Meteor.call "removePost", e.currentTarget.id
            )

        'click .edit': (e)->
            e.stopPropagation()
            Session.set "shopId", ''
            Session.set "upload_images",new Array()
            Session.set "add_partner_id", e.currentTarget.id
            Session.set "add_partner_type", "edit"
            PUB.page("add_partner")

        "click .partner_lists":(event)->
            if Session.get "cancelBubble"
                return

            post_id = event.currentTarget.id
            type = event.currentTarget.getAttribute('tag')
            if type is 'local_service'
                Session.set('postType', event.currentTarget.getAttribute('tag'))
                console.log ("view is blackboard_detail, current target id is " + post_id)
                Session.set "blackboard_post_id", post_id
                PUB.page("blackboard_detail")
            else if type is 'pub_board'
                Session.set 'partnerId',event.currentTarget.id
                Session.set "blackboard_post_id", event.currentTarget.id
                Session.set "blackborad_footbar_view", "blackboard_footbar_nav"
                Session.set "return_view","partner_finding"
                Session.set "document.body.scrollTop", document.body.scrollTop
                #      Session.set "view", "partner_detail"
                #      Meteor.call 'page','partner_detail',(e)->
                Session.set "partner_return_view", Session.get("view")
                PUB.page("partner_detail")
        "click li":(e)->
            Session.set "cancelBubble", true
            post = Posts.findOne({_id:e.currentTarget.parentNode.id})
            images = new Array()
            post.images.forEach (item)->
                images.push item.url
            Session.set "images_view_images", images
            Session.set "images_view_images_selected", e.currentTarget.id
            PUB.page("images_view")
            Meteor.setTimeout ->
                Session.set "cancelBubble", false
                300
    Template.blackboard_img.rendered=->
        Session.set "cancelBubble", false
    Template.blackboard_img.helpers
        img:->
            Session.get "blackboard_img"
    Template.blackboard_img.events
        "click ":->
            PUB.back()
    Template.blackboard_footbar.events


    # 底部工具栏
    Template.blackboard_footbar.helpers
        footbar_view:->
            view = Session.get "blackborad_footbar_view"
            if view is '' or view is undefined
                view = "blackboard_footbar_nav"

            console.log 'footbar_view is ' + view
            view

    Template.blackboard_footbar_reply.rendered=->
        Session.set "blackborad_reply_to_userId", undefined
        $("#comment").attr("placeholder", "说点什么")
    Template.blackboard_footbar_reply.events
        # 返回
        "click .back":->
            Session.set "blackborad_reply_to_userId", undefined
            Session.set "blackborad_footbar_view", "blackboard_footbar_nav"
        'click #comment': ->
            if Meteor.user() is null
                window.PUB.toast '请登录后评论!'
                return

            Session.set "reply_return_view", Session.get("view")
            Session.set "view", 'blackboard_input'
        'click .say_guide': ->
            if Meteor.user() is null
                window.PUB.toast '请登录后评论!'
                return

            Session.set "reply_return_view", Session.get("view")
            Session.set "view", 'blackboard_input'
#        "focus #comment":->
#            # TODO:需要处理IOS的fixed定位问题
#            if Meteor.isCordova
#                if device.model.indexOf("iPhone") >= 0 or device.model.indexOf("iPad") >= 0
#                    $(".partner_detail").css 'padding-bottom','0';
#                    $("#footbar").css 'position','relative'
#                    $(document).scrollTop($(document).height())
#                    console.log ("Frank device.model = "+device.model)
#        "blur #comment":->
#            # TODO:需要处理IOS的fixed定位问题
#            if Meteor.isCordova
#                if device.model.indexOf("iPhone") >= 0 or device.model.indexOf("iPad") >= 0
#                    $(".partner_detail").css 'padding-bottom','54px'
#                    $("#footbar").css 'position','fixed'
#        "click .submit":->
#            $("#new-reply").submit()
#        "submit .new-reply": (event)->
#            if Meteor.user() is null
#                window.PUB.toast '请登录后操作!'
#                return
#
#            # This function is called when the new task form is submitted
#            text = event.target.comment.value;
#            if text is ""
#                window.PUB.toast "内容不能为空"
#                return false
#
#            console.log('User information is ' + Meteor.user().username)
#            token = PushToken.find({userId:Meteor.user()._id}).fetch()
#            if token.length >=1
#                pushType = token.type
#                tokenValue = token.token
#            postId = Session.get "blackboard_post_id"
#            username = Meteor.user().username
#            userId = Meteor.user()._id
#            userPicture = ''
#            replyId = ""
#
#            for x in [1..32]
#                n = Math.floor(Math.random() * 16.0).toString(16)
#                replyId += n
#
#            if Meteor.user().profile and Meteor.user().profile.picture
#                userPicture = Meteor.user().profile.picture
#            try
#                Posts.update {
#                    _id: postId,
#                }, {
#                    $push: {
#                        replys: {
#                            _id: replyId
#                            userId : Meteor.user()._id
#                            username: if Meteor.user().profile.nike is undefined or Meteor.user().profile.nike is "" then Meteor.user().username else Meteor.user().profile.nike
#                            toUserId: Session.get("blackborad_reply_to_userId")
#                            comment: text
#                            userPicture: userPicture
#                            createdAt: new Date()
#                        }
#                    }
#                }
#            catch error
#                console.log error
#            event.target.comment.value = ""
#            Session.set "blackborad_reply_to_userId", undefined
#            $("#comment").attr("placeholder", "说点什么")
##            Meteor.setTimeout ->
##                document.body.scrollTop = document.body.scrollHeight
##                300
#            false
    # 底部工具栏 -> 导航条
    Template.blackboard_footbar_nav.helpers
        is_click_good: ->
            post = Posts.findOne {_id: Session.get("blackboard_post_id")}
            if post.goodUsers is undefined
                true
            else
                for item in post.goodUsers
                    if item.userId is Meteor.userId()
                        return false#只能点一次
                true
        is_show_join:->
            if Session.get("view") is "partner_detail" or Session.get("view") is "activity_content"
                return true
            false
    Template.blackboard_footbar_nav.events
        # 点赞
        "click #to_good": (event)->
            if Meteor.user() is null
                window.PUB.toast '请登录后操作!'
                return

            post = Posts.findOne {_id: Session.get("blackboard_post_id")}
            is_click_good = false;

            if post.goodUsers != undefined
                for item in post.goodUsers
                    if item.userId is Meteor.user()._id
                        is_click_good = true
                        break #只能点一次

            if is_click_good
                Posts.update {
                    _id: Session.get "blackboard_post_id"
                }, {
                    $inc: {
                        good:-1
                    },
                    $pull: {
                        goodUsers : {
                            userId: Meteor.user()._id
                        }
                    }
                }
            else
                Posts.update {
                    _id: Session.get "blackboard_post_id"
                }, {
                    $inc: {
                        good:1
                    },
                    $push: {
                        goodUsers : {
                            userId: Meteor.user()._id
                            userName: Meteor.user().username
                            createdAt: new Date()
                        }
                    }
                }
        "click .buttons li": (e)->
            id = e.currentTarget.id

            if id is "to_reply" # 评论
                if Meteor.user() is null
                    window.PUB.toast '请登录后评论!'
                    return

                Session.set "blackborad_reply_to_userId", undefined
                Session.set "reply_return_view", Session.get("view")
                Session.set "view", 'blackboard_input'
            else if id is "to_chat" # 搭话
                if Meteor.user() is null
                    window.PUB.toast '请登录后搭话!'
                    return

                post = Posts.findOne {_id: Session.get("blackboard_post_id")}
                if Meteor.userId() is post.userId
                    window.PUB.toast "不能和自己搭话！"
                    return

                Session.set('chat_home_business', false)
                Session.set "chat_to_userId", post.userId
                Session.set 'chat_return_view', Session.get("view")
                PUB.page("chat_home")
                Meteor.setTimeout ->
                    document.body.scrollTop = document.body.scrollHeight
                    300
