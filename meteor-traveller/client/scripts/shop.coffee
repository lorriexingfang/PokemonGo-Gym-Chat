# Author: feiwu
# Modify: 2014-11-22
# Space 4
if (Meteor.isClient) 
    Session.setDefault "shopName", "无"
    Session.setDefault "shop_seach_key", ""
    # template -> shop
    Template.shop.rendered=->
        # Session.set "shopId", Shops.findOne()._id
        Session.set 'shop_view','shop_summary'
    Template.shop.helpers
        shop_view:->
            Session.get "shop_view"
        shop:->
            shopId = Session.get "shopId"
            shop = Meteor.users.findOne({_id: shopId})
            shop
    Template.shop.events
        # 返回
        "click .leftButton": ->
#            PUB.back()
            window.page.back()
        # tab
        "click .tabs .tab": (e)->
            # console.log Meteor.users.findOne({username: "moya"})._id
            $(".tabs .tab").removeClass "hover"
            $("#" + e.currentTarget.id).addClass "hover"
            Session.set "shop_view", e.currentTarget.id
        # map
#        "click .map": ->
#            shopId = Session.get "shopId"
#            shop = Meteor.users.findOne({_id: shopId}) 
#            Session.set "view", "shop_map"
            
    Template.shop_partner_list.helpers
        lists:->
            shopId = Session.get "shopId"
            Posts.find({type: 'pub_board',shopId: shopId}, {sort: {createdAt: -1}})
            
    # template -> shop_summary
    Template.shop_summary.helpers
        shop:->
            shopId = Session.get "shopId"
            shop = Meteor.users.findOne({_id: shopId}) 
            shop
        is_service: (val)->
            shopId = Session.get "shopId"
            shop = Meteor.users.findOne({_id: shopId}) 
            service = shop.service.split(",")
            for item in service
                if item == val
                    return ""
            "none"
            
    # tmeplate -> map
    Template.shop_map.rendered=->
        shopId = Session.get "shopId"
        shop = Meteor.users.findOne({_id: shopId}) 
        width = $("#allmap").width()
        $("#allmap").html("<img src='http://api.map.baidu.com/staticimage?width=" + width + "&height=400&center=&markers=" + shop.location.coordinates[0] + "," + shop.location.coordinates[1] + "&zoom=13&markerStyles=l,A,0xff0000' />")
    Template.shop_map.events
        # 返回
        "click .leftButton": ->
            PUB.back()
        # template -> list
    Template.shop_list.helpers
        shops: ->
            key = Session.get "shop_seach_key"
            if key == ""
                Meteor.users.find {'profile.isBusiness': 1}
            else
                e = RegExp(key)
                Meteor.users.find {'profile.isBusiness': 1,'profile.business':e, 'profile.business': {$ne: ''}, 'profile.business': {$ne: null}}
        hasname: (value)->
            if value is '' or value is null or value is undefined
                false
            else
                true
    Template.shop_list.events
        "click .leftButton":->
            PUB.back()
        "click .shop":(event)->
            if event.currentTarget.getAttribute('name') == "无"
                Session.set "shopName", "无"
                Session.set "shopId",undefined
                PUB.back()
            else
                Session.set 'shopId',event.currentTarget.getAttribute('shopId')
                Session.set 'shopName',event.currentTarget.getAttribute('shopName')
                PUB.back()
        "click .shop_key": (event)->
            $('#' + event.currentTarget.id).bind 'input propertychange', ->
                Session.set "shop_seach_key", $(this).val()