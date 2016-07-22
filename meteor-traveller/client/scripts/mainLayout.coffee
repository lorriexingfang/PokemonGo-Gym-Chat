if Meteor.isClient
    Session.setDefault('BusinessNotFromTuya', false)
    Session.setDefault "channel","wifiIndex"
    Template.footer.rendered=->
#        $('#'+Session.get('view')).css 'color','#00a1e9'
    Template.footer.helpers
        is_channerl: (channelName)->
            return Session.equals('channel', channelName)
        focus_style:(channelName)->
            # console.log "channel is "+channelName
            channel = Session.get "channel"
            if channel is channelName
                return "focus"
            else
                return ""
        wait_read_count:->
            if Meteor.user() is null
                0
            else
                waitReadCount = 0
                # msgType: {$ne: 'system'} # do not know why we do not show system message alert
                chatUsers = ChatUsers.find({userId: Meteor.userId(), waitReadCount: {$gt: 0}}).forEach (item)->
                    waitReadCount += item.waitReadCount
                waitReadCount
        is_wait_read_count: (count)->
            count > 0
    Template.footer.events
        "click .item":(event)->
            # 是否能连接到服务器
#            if !Meteor.status().connected
#                window.plugins.toast.showLongBottom '无法获取数据，请检查网络设置'
        
            # 首页/搭伙/当地人/我
            Session.set "channel",event.currentTarget.id
#            Session.set 'view',event.currentTarget.id
       #     $('#'+event.currentTarget.id).css 'color','#00a1e9'
            # 我
#            if event.currentTarget.id is "dashboard"
#                Session.set("login_return_view",'')
#                Session.set 'my_view','my_service'
#                if Meteor.user
#                    Meteor.subscribe('chats')
#                    Meteor.subscribe('chatUsers')
#            console.log("##RDBG footer click: " + event.currentTarget.id)
            PUB.page(event.currentTarget.id)
            Template.public_loading_index.__helpers.get('close')()
            Session.set('BusinessNotFromTuya', false)
    
    Session.setDefault('isDialogView', false)
    Session.setDefault('dialogView', false)

    Template.mainLayout.helpers
        dialog_view: ()->
            return Session.get('dialogView')
        isDialog: ()->
            return Session.equals('isDialogView', true)
        #bishen,在任何地方只要修改view这个值，页面就可切换
        view:->
            view = Session.get 'view'
            # We need postType to reuse Post template
            if view is 'local_service'
                Session.set 'postType', 'local_service'
            else if view is 'pub_board' or view is 'partner'
                Session.set 'postType','pub_board'
            console.log Session.get("document_body_scrollTop")
            Meteor.setTimeout(
                ()->
                    #console.log "set 'document.body.scrollTop' is " + Session.get("document_body_scrollTop")
                    document.body.scrollTop = Session.get("document_body_scrollTop")
                300
            )
            view
        is_show_footer:->
            if Session.equals('dialogView', 'wifiPubwifiReply') and Session.equals('isDialogView', true)
                return false
            else if Session.equals('isDialogView', true) and (Session.equals('dialogView', 'scoresSubmitTips') or Session.equals('dialogView', 'scoresSubmitForm'))
                return false
            else if(Session.equals( 'view', 'wifiPubWifi') and Template.wifiPubWifi.__helpers.get('isBack')())
                return false
            else if (Session.equals('hide_footer_bar', true))
                return false
            return Session.equals( 'view', 'pub_board') or Session.equals( 'view', 'my_message') or Session.equals( 'view', 'wifiOffline') or Session.equals( 'view', 'wifiOnline') or Session.equals( 'view', 'wifiUserWifi') or Session.equals( 'view', 'dashboard') or Session.equals( 'view', 'login') or Session.equals( 'view', 'my_info') or Session.equals( 'view', 'login_ing') or Session.equals( 'view', 'my_message_guest') or Session.equals( 'view', 'partner_finding') or Session.equals( 'view', 'wifiPubWifi')
        is_hide_footer:->
            Session.equals( 'view', 'blackboard_detail') || Session.equals('view', 'add_partner') || Session.equals( 'view', 'local_service_detail') || Session.equals( 'view', 'partner_detail') || Session.equals('view', 'deal_page') ||Session.equals( 'view', 'activity_detail') || Session.equals('view', 'partner_finding') || Session.equals( 'view', 'partner_theme') || Session.equals( 'view', 'partner_activities') || Session.equals( 'view', 'chat_home') || Session.equals('view', 'viewers') || Session.equals("view", "images_view") || Session.equals( 'view', 'activity_content') || Session.equals( 'view', 'notes_detail') || Session.equals( 'view', 'blackboard_input') || Session.equals( 'view', 'chat_input') || Session.equals( 'view', 'event_2015_01_index')|| Session.equals( 'view', 'notes_add')|| Session.equals( 'view', 'notes_index')|| Session.equals( 'view', 'business_user')|| Session.equals( 'view', 'group_msg_send')|| Session.equals( 'view', 'shop_manager')|| Session.equals( 'view', 'edit_wifi')
        data:->
            Session.get("view_data")
    Meteor.startup ()->
        ##Set default view to pub_board
        #Session.setDefault 'view','wifiIndex'
        #Session.setDefault 'referrer','pub_board'
        ####### bishen #########
        @umappkey = '547e860dfd98c58da5001753'
