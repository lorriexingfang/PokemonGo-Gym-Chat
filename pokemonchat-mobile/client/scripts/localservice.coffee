# Space 4
if Meteor.isClient
    Template.local_service_home.rendered=->
        #Meteor.subscribe 'localserviceUsers', Session.get("city")
    Template.local_service_home.helpers
        usersA:->
            city = Session.get("city")
            if city is "附近" and Session.get("location_city") isnt undefined
                city = Session.get("location_city")
            Meteor.users.find({"profile.city": city, "profile.isVip": 1, 'profile.tags': {$in:['旅游达人','俱乐部']}},{sort: {"profile.createdAt": -1},limit:4})
        usersB:->
            city = Session.get("city")
            if city is "附近" and Session.get("location_city") isnt undefined
                city = Session.get("location_city")
            Meteor.users.find({"profile.city": city, "profile.isVip": 1, 'profile.tags': {$in:['客栈']}},{sort: {"profile.createdAt": -1},limit:4})
        usersC:->
            city = Session.get("city")
            if city is "附近" and Session.get("location_city") isnt undefined
                city = Session.get("location_city")
            Meteor.users.find({"profile.city": city, "profile.isVip": 1, 'profile.tags': {$in:['吃货']}},{sort: {"profile.createdAt": -1},limit:4})
    Template.local_service_home.events
        "click .user_list": (event)->
            Session.set "localservice_user_tag", event.currentTarget.id
            PUB.page("localservice_user")

    Template.local_service_home_user_list_a.helpers
        show_username: (user)->
            if user.profile.nike is undefined or user.profile.nike is ""
                user.username
            else
                user.profile.nike
        is_undefined: (picture)->
            if picture == "" or picture == undefined
                true
            else
                false  
        get_tag: (tags)->
            for i in[0..tags.length-1]
                if tags[i] is '旅游达人' or tags[i] is '俱乐部'
                    return findImageByName(tags[i])
            findImageByName(tags[0])
    Template.local_service_home_user_list_a.events
        "click .home_user": (event)->
            Session.set "locservice_user_id", event.currentTarget.id
            console.log "locservice_user_id is "+event.currentTarget.id
            Session.set "myview", "home_detailed"
            PUB.user_home(event.currentTarget.id)
    Template.local_service_home_user_list_b.helpers
        show_username: (user)->
            if user.profile.nike is undefined or user.profile.nike is ""
                user.username
            else
                user.profile.nike
        is_undefined: (picture)->
            if picture == "" or picture == undefined
                true
            else
                false  
        get_tag: (tags)->
            findImageByName "客栈"
    Template.local_service_home_user_list_b.events
        "click .home_user": (event)->
            Session.set "locservice_user_id", event.currentTarget.id
            console.log "locservice_user_id is "+event.currentTarget.id
            Session.set "myview", "home_detailed"
            PUB.user_home(event.currentTarget.id)
    Template.local_service_home_user_list_c.helpers
        show_username: (user)->
            if user.profile.nike is undefined or user.profile.nike is ""
                user.username
            else
                user.profile.nike
        is_undefined: (picture)->
            if picture == "" or picture == undefined
                true
            else
                false  
        get_tag: (tags)->
            findImageByName '吃货'
    Template.local_service_home_user_list_c.events
        "click .home_user": (event)->
            Session.set "locservice_user_id", event.currentTarget.id
            console.log "locservice_user_id is "+event.currentTarget.id
            Session.set "myview", "home_detailed"
            PUB.user_home(event.currentTarget.id)
            
#    Template.local_service_home_user_list.helpers
#        show_username: (user)->
#            if user.profile.nike is undefined or user.profile.nike is ""
#                user.username
#            else
#                user.profile.nike
#        is_undefined: (picture)->
#            if picture == "" or picture == undefined
#                true
#            else
#                false  
#                
#        is_vip: (vip)->
#            vip is 1
#        get_tag: (tags)->
#            tags[0]
#    Template.local_service_home_user_list.events
#        "click .home_user": (event)->
#            Session.set "locservice_user_id", event.currentTarget.id
#            console.log "locservice_user_id is "+event.currentTarget.id
#            Session.set "myview", "home_detailed"
#            PUB.user_home(event.currentTarget.id)
            
    #列表
    Template.local_service_list.helpers
        page_title:->
            Session.get("localservice_user_tag")
    Template.local_service_list.events
        "click .button_left": ->
            Session.set "locservice_user_id", ""
            PUB.back()
    
    #用户
    Template.localservice_user.helpers
        page_title:->
            title = '当地人'
            switch Session.get("localservice_user_tag")
                when "驴友营地" then title = '驴友营地(旅游达人)'
                when "背包客的胡同" then title = '背包客的胡同(客栈 青年旅舍)'
                when "美食一条街" then title = '美食一条街(当地吃货)'
            title
        users: ->
            tags = Session.get("localservice_user_tag")
            queryKey = ""
            switch tags
                when "驴友营地" then queryKey = ["旅游达人","俱乐部"]
                when "背包客的胡同" then queryKey = ["客栈"]
                when "美食一条街" then queryKey = ["吃货"]
            if Session.get("city") is "附近" and Session.get("location_city") isnt undefined
                Meteor.users.find({"profile.isVip": 1,"profile.city": Session.get("location_city"), 'profile.tags': {$in:queryKey}},{sort: {"profile.createdAt": -1}})
            else
                Meteor.users.find({"profile.city": Session.get("city"), "profile.isVip": 1, 'profile.tags': {$in:queryKey}},{sort: {"profile.createdAt": -1}})
    Template.localservice_user.events
        "click .button_left": ->
#            PUB.back()
            window.page.back()
    Template.localservice_user_list.helpers
        show_username: (user)->
            if user.profile.nike is undefined or user.profile.nike is ""
                user.username
            else
                user.profile.nike
        is_undefined: (picture)->
            if picture == "" or picture == undefined
                true
            else
                false
        user_sex: (sex)->
            if sex == "男"
                "male"
            else
                "female"
        is_vip: (vip)->
            vip is 1
        is_tags: (tags)->
            if tags is undefined or tags.length <= 0
                return false
            true
        get_tag: (tags)->
            tags[0]
    Template.localservice_user_list.events
        "click .layer": (event)->
            Session.set "locservice_user_id", event.currentTarget.id
            #console.log "locservice_user_id is "+event.currentTarget.id
            Session.set "myview", "home_detailed"
            PUB.user_home(event.currentTarget.id)
    Template.localservice_user_detail.helpers
        user: ->
             Meteor.users.findOne({_id: Session.get("locservice_user_id")})
        is_undefined: (picture)->
            if picture == "" or picture == undefined
                true
            else
                false
        user_sex: (sex)->
            if sex == "男"
                "male"
            else
                "female"
    Template.localservice_user_detail.events
        "click .button_left": ->
            PUB.back()
        "click .info_list": ->
            PUB.page("localservice_info_detail")
        "click .homepage": ->
            #TODO:
        "click .user_pic":->
            Session.set "myview", "home_detailed"
            PUB.user_home(Session.get("locservice_user_id"))
            
    Template.local_service_wifi.helpers
        is_undefined: (picture)->
            if picture == "" or picture == undefined
                true
            else
                false  
                
        show_username: (user)->
            if user.profile.nike is undefined or user.profile.nike is ""
                user.username
            else
                user.profile.nike
                
        is_wifi:()->
            Session.get("connection_wifi") is true
            
        is_no_users:()->
            Meteor.users.find({'profile.wifi.BSSID': Session.get("user_wifi_info").BSSID, _id: {$ne: Meteor.userId()}}).count() <= 0
            
        users:()->
            Meteor.users.find({'profile.wifi.BSSID': Session.get("user_wifi_info").BSSID, _id: {$ne: Meteor.userId()}})
            
    Template.local_service_wifi.events
        "click .home_user": (event)->
            Session.set "locservice_user_id", event.currentTarget.id
            console.log "locservice_user_id is "+event.currentTarget.id
            Session.set "myview", "home_detailed"
            PUB.user_home(event.currentTarget.id)