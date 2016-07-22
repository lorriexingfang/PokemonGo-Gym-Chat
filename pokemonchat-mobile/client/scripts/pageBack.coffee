class Page
  _config = undefined
  _showConfirm = false

  constructor: ()->

    # 需要触发'Android'的返回键请配置如下信息，并在返回的事件如下调用：window.page.back()
    _config = [
      # 搭伙列表
      {
        view: 'partner_theme'
        back: ()->
          return_view = Session.get 'partner_theme_return_view'
          if return_view is 'partner_theme' or return_view is '' or return_view is undefined
            Session.set 'view', 'partner'
          else
            Session.set 'view', return_view
      }
      # 正在搭伙
      {
        view: 'partner_finding'
        back: ()->
          return_view = Session.get 'partner_finding_return_view'
          if return_view is 'partner_finding' or return_view is '' or return_view is undefined
            Session.set 'view', 'partner'
          else
            Session.set 'view',Session.get 'partner_finding_return_view'
      }
      # 来搭伙
      {
        view: 'add_partner'
        back: 'pub_board'
      }
      # 搭伙详情(入口较多)
      {
        view: 'partner_detail'
        back: ()->
          return_view = Session.get 'partner_return_view'
          if return_view is 'partner_detail' or return_view is '' or return_view is undefined
            Session.set 'view', 'partner'
          else
            Session.set 'view',Session.get 'partner_return_view'
      }
      # 最新活动-列表
      {
        view: 'partner_activities'
        back: 'partner'
      }
      # 最新活动-详情
      {
        view: 'activity_content'
        back: 'partner_activities'
      }
      #商家管理
      {
        view:'shop_manager'
        back:'dashboard'
      }
      {
        view:'edit_wifi'
        back:'shop_manager'
      }
      # 游记列表
      {
        view: 'notes_index'
        back: ()->
          return_view = Session.get 'articleType'
          if return_view is 'notes' or return_view is '' or return_view is undefined
            Session.set 'view', 'partner_theme'
          else
            Session.set 'view', 'shop_manager'
        data: ()->
          {tag: Session.get("tag")}
      }
      # 游记详情
      {
        view: 'notes_detail'
        back: ()->
          bbb = Session.get('articleViewBack')
          if bbb is 'wifiOnline'
            Session.set 'articleViewBack' ,''
            Session.set "view", "wifiOnline"
          else
            Session.set "view", "notes_index"
        data: ()->
          {tag: Session.get("tag")}
      }
      # 增加游记
      {
        view: 'notes_add'
        back: ()->
          Session.set('tag', Session.get("tag"))
          Session.set("view_data", {tag: Session.get("tag")})

          if(Session.get('notes_add_return') is undefined or Session.get('notes_add_return') is '')
            Session.set('view', 'notes_index')
          else
            Session.set('view', Session.get('notes_add_return'))
          Session.set('notes_add_return', '')
      }
      # 编辑游记
      {
        view: 'notes_edit'
        back: ()->
          Session.set('tag', Session.get("tag"))
          Session.set("view_data", {tag: Session.get("tag")})

          if(Session.get('notes_edit_return') is undefined or Session.get('notes_edit_return') is '')
            Session.set('view', 'notes_index')
          else
            Session.set('view', Session.get('notes_edit_return'))
          Session.set('notes_edit_return', '')
      }
      # 当地服务详情
      {
        view: 'blackboard_detail'
        back: 'local_service'
      }
      # 当地人列表
      {
        view: 'localservice_user'
        back: 'local_service'
      }
      # 增加当地服务
      {
        view: 'blackboard_add'
        back: 'local_service'
      }
      # 城市
      {
        view: 'city'
        back: 'local_service'
      }
      # 个人主页（入口较多）
      {
        view: 'home_info'
        back: ()->
          try
            PUB.back()
          catch error
            console.log error
            Session.set "view", "pub_board"
      }
      # 商户
      {
        view: 'shop'
        back: 'partner_detail'
      }
      # ============我的======================
      {
        view: 'my_vip'
        back: 'my_info'
      }
      {
        view: 'edit_tel'
        back: ()->
          Session.set 'view',Session.get 'referrer'
      }
      {
        view: 'edit_identity'
        back: 'my_vip'
      }
      {
        view: 'my_business'
        back: 'my_info'
      }
      {
        view: 'edit_business'
        back: 'my_business'
      }
      {
        view: 'edit_address'
        back: 'my_business'
      }
      {
        view: 'edit_text'
        back: 'my_business'
      }
      {
        view: ',my_nike,my_sex,my_birthday,my_province,my_signature,'
        back: 'my_info'
      }
      # =======关于游喳=======
      {
        view: 'about_youzha'
        back: 'my_info'
      }
      # 像册（入口较多）
      {
        view: 'images_view'
        back: ()->
          try
            PUB.back()
          catch error
            console.log error
            Session.set "view", "pub_board"
      }
      # 评论文本输入框
      {
        view: 'blackboard_input'
        back: ()->
          Session.set 'view',Session.get 'reply_return_view'
      }
      # 搭话
      {
        view: 'chat_home'
        back: ()->
          # 处理我的消息状态
          Session.set "chat_to_user", undefined
          Meteor.call "setChatReadStatusNew", Session.get("chat_to_userId"), Session.get('chat_home_business'), ()->

          Session.set('view_data', {id: Session.get('blackboard_post_id')})
          Session.set('chat_home_business', false)
          Session.set 'view', Session.get("chat_return_view")
          if Session.get("chat_return_view") is 'chat_home'
            # 页面滚到底部
            Meteor.setTimeout(
              ()->
                document.body.scrollTop = document.body.scrollHeight
              500
            )
          else if(Session.get("chat_return_view") is 'wifiOnline')
            Session.set('view', 'wifiOnline')
      }
      # 搭话文本输入框
      {
        view: 'chat_input'
        back: ()->
          Session.set('chat_home_business', false)
          Session.set('view', 'chat_home')
      }
      # 2015-01 期活动
      {
        view: 'event_2015_01_index'
        back: 'partner'
      }
      # wifi 小黑板
      {
        view: 'wifiReport'
        back: 'wifiOnline'
      }
      # wifi 商家
      {
        view: 'wifiOnline'
        back: ()->
          if Session.get('channel') is 'wifiIndex' and Session.get('wifi-business-seaching') isnt true
            Session.set('view', 'wifiPubWifi')
          else if(Session.get('online-return') isnt '' and Session.get('online-return') isnt undefined)
            Session.set('view', Session.get('online-return'))
            Session.set('online-return', '')
          else if Template.wifiOnline.__helpers.get('wifiOnline_blazeload')() isnt null
            Template.wifiOnline.__helpers.get('close')()
          else
            Session.set('view', 'partner_finding')
      }
      # 搜索
      {
        view: 'searching'
        back: ()->
          resultPage = Session.get 'resultPage'
          if resultPage is 'findkey'
            Session.set('resultPage', 'search_top')
          else
            Session.set('view', 'pub_board')
      }

      # 商家管理
      {
        view: 'business_user'
        back: 'shop_manager'
      }
      {
        view: 'group_msg_send'
        back: ()->
          Session.set('group_msg_send_target', '')
          Session.set('view', 'shop_manager')
      }
      #我的搭伙
      {
        view: 'my_service'
        back: 'my_info'
      }
      #我的小黑板
      {
        view: 'my_blackboard'
        back: 'my_info'
      }
      #增加热点
      {
        view: 'wifiAddWifi'
        back: 'wifiPubWifi'
      }
      #WIFI密码
      {
        view: 'wifiPubwifiPasswd'
        back: 'wifiPubWifi'
      }
      #小店地址
      {
        view: 'wifiPubwifiAddress'
        back: 'wifiPubWifi'
      }      
      #来涂鸦
      {
        view: 'wifiPubwifiReply'
        back: ()->
          if(Session.get('isDialogView', true))
            Session.set('isDialogView', false)
          else
            Session.set('wifiPubWifi-view', 'wifiPubWifiIndex')
            Session.set('view', 'wifiPubWifi')
      }
      #添加的WIFI
      {
        view: 'wifiPubWifi'
        back: ()->
          if(Session.get('isDialogView', true))
            Session.set('isDialogView', false)
          else
            if(Template.wifiPubWifi.__helpers.get('isBack')())
              Template.wifiPubWifi.__helpers.get('goBack')()
            else
              true
      }
      #招贴画管理
      {
        view: 'shop_manager_banner'
        back: 'shop_manager'
      }
      #什么是招贴画
      {
        view: 'shop_manager_banner_tip'
        back: 'shop_manager_banner'
      }
      #添加超级热点
      {
        view: 'wifiPubwifiAddSuperAP'
        back: 'wifiPubWifi'
      }
      {
        view: 'scoresSubmitTips'
        back: ()->
          if(Session.get('isDialogView', true))
            Session.set('isDialogView', false)
          else
            Session.set('wifiPubWifi-view', 'wifiPubWifiIndex')
            Session.set('view', 'wifiPubWifi')
      }
      {
        view: 'scoresSubmitForm'
        back: ()->
          Session.set('dialogView', 'scoresSubmitTips')
      }
      # 服务告知
      {
        view: 'deal_page'
        back: ()->
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
          undefined
      }
      # 注册页面
      {
        view: 'registered'
        back: 'login'
      }
      # 我的钱包
      {
        view: 'my_wallet'
        back: 'my_info'
      }
    ]

  saveScrollTop: (curView, newView)->
    view = Session.get(curView)
    #console.log("saveScrollTop: view="+view+", newView="+newView)
    needSavePages = ['wifiPubWifi']
    flag = 0
    for page in needSavePages
      if view is page
        flag = 1
        break
    if flag is 0
      return
    history = Session.get('history_'+view)
    if history is undefined or history is ""
      history = new Array()
    history.push {
      scrollTop: document.body.scrollTop
    }
    if (history.length > 3)
      history.splice(0, history.length-3)
    #console.log("Frank: view="+view+", scrollTop="+document.body.scrollTop)
    #for page in history
    #  console.log("  set, scrollTop="+page.scrollTop)
    Session.set 'history_'+view, history

  restoreScrollTop: (view, newView)->
    curView = Session.get(view)
    #console.log("restoreScrollTop: curView="+curView+", newView="+newView)
    history = Session.get('history_'+newView)
    unless history is undefined or history is ""
      if history.length > 0
        page = history.pop()
        Session.set "document_body_scrollTop", page.scrollTop
        #console.log("Frank: newView="+newView+", document_body_scrollTop="+page.scrollTop)
        #for page in history
        #  console.log("  get, scrollTop="+page.scrollTop)
        Session.set 'history_'+newView, history

  #resetJumpTabPageScrollTop: (view)->
  #  Session.set('history_'+curView, 0);

  jumpTabPageAndSaveScrollTop: (view, newView)->
    curView = Session.get(view)
    if curView?
      Session.set('history_'+curView+'_scrollTop', document.body.scrollTop);
      console.log("document.body.scrollTop = "+document.body.scrollTop+', curView='+curView+', newView='+newView)
      if newView is 'wifiPubWifiIndex'
        historyScrollTop = 0
      else
        historyScrollTop = Session.get('history_'+newView+'_scrollTop')
        if historyScrollTop is undefined
          historyScrollTop = 0
      #document.body.scrollTop = historyScrollTop
      Session.set("document_body_scrollTop", historyScrollTop)
      console.log("historyScrollTop = "+historyScrollTop)

  # 回退
  back: ()->
    front_page_flag = undefined
    view = Session.get("view")
    for item in _config
      if view is item.view or item.view.indexOf(",#{view},") >= 0
        Session.set('disable_set_scrollTop', true)
        if typeof(item.back) is 'function'
          front_page_flag = item.back()
        else
          if item.data isnt undefined
            if typeof(item.data) is 'function'
              for key in item.data()
                Session.set key, item.data()[key]
              console.log item.data()
              Session.set "view_data", item.data()
            else
              for key in item.data
                Session.set key, item.data[key]
              console.log item.data
              Session.set "view_data", item.data
          Session.set "view", item.back
        Session.set('disable_set_scrollTop', false)
        if front_page_flag is undefined
          return

    # 防止重复弹出提示窗口
    if !_showConfirm
      _showConfirm = true
      console.log('exit app?')
      if Meteor.isCordova
        navigator.notification.confirm(
          '您确定要退出程序吗？'
          (index)->
            _showConfirm = false
            if index is 1
              navigator.app.exitApp()
          '退出程序'
          ['确定','取消']
        )

if !window.page
  window.page = new Page()
