#@bishen.org
#公共函数
@PUB = 
    # 去用户空间
    'user_home':(userId)->
        Session.set 'userId',userId
        Session.set 'homereferrer',Session.get('view')
        Session.set 'myview','home_service'
        PUB.page("home_info")
        #Session.set 'view','home_info'
        return
    # 发布搭伙信息
    'add_partner':->
        Session.set 'partnerreferrer',Session.get('view')
        PUB.page("add_partner")
        #Session.set 'view','add_partner'
        return
    # 该方法实现页面切换
    'page':(pageName, data)->
        if pageName is 'images_view'
          Template.images_view.__helpers.get('show')();
          return
        #console.log "The PUB.page() is deprecating!! Use Session.set('view', pageName)"
        history = Session.get("history_view")
        view = Session.get("view")
        if history is undefined or history is ""
            history = new Array()
        footerPages = ['pub_board', 'partner', 'local_service', 'dashboard']
        #if current view is one of footer pages, and record the position of these pages
        for page in footerPages
            if view is page
                Session.set 'document_body_scrollTop_'+view, document.body.scrollTop
                break
        #if pageName is one of footer pages, we will clear history and need to return back to the last position
        Session.set 'document_body_scrollTop', 0
        for page in footerPages
            if pageName is page
                history = []
                value = Session.get 'document_body_scrollTop_'+page
                if value is undefined
                    value = 0
                Session.set 'document_body_scrollTop', value
                break
        unless view is undefined or view is ""
            if history.length > 0 and view is history[history.length-1].view
                history[history.length-1].scrollTop = document.body.scrollTop
            else
                history.push {
                    view: view
                    data: Session.get("view_data")
                    scrollTop: document.body.scrollTop
                }
            Session.set "history_view", history
        #if Session.get('view') isnt 'partner_detail' and Session.get('view') isnt 'add_partner'
        #    Session.set 'referrer',Session.get('view')
#        Meteor.setTimeout ->
#            document.body.scrollTop = 0
#            350
        Session.set 'view_data', data
        Session.set 'view',pageName
        return
    # 返回上一页
    'back':->
        #console.log "The PUB.back() is deprecating!! Use window.page.back()"
        history = Session.get("history_view")
        unless history is undefined or history is ""
            if history.length > 0
                page =  history.pop()
                Session.set "document_body_scrollTop", page.scrollTop
                Session.set "history_view", history
                
                Session.set "view_data", page.data
                Session.set "view", page.view
        #nowPage = Session.get('view')
        #Session.set 'view',Session.get('referrer')
        #if nowPage isnt 'partner_detail' and nowPage isnt 'add_partner'
        #    Session.set 'referrer',nowPage
        return
    'toast':(msg)->
        Dialog.toast(msg)
    'toast2':(msg)->
        Dialog.toast2(msg)
    'longtoast':(msg)->
        Dialog.longtoast(msg)
    "confirm":(msg, callback)->
        Dialog.confirm(
            msg,
            ['确定','取消']
            (index)->
                if(index is 0)
                    callback()
          
        )
                
#       可以浏览图片，放大，缩小，下一张
#        items 格式
#        items = [
#            {src: '/home/111.jpg',w: 300,h: 350},
#            {src: '/home/112.jpg',w: 300,h: 450}
#          ]
    "photos":(items)->
        window.openPhotoSwipe(items)