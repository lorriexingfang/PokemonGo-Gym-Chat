if Meteor.isClient
  Router.configure {
    layoutTemplate: 'defaultLayout'
  }

  Router.route '/', ()->
    window.location = 'http://58dahuo.duapp.com/'

  Router.route '/stat', ()->
    this.render 'stat'
    return

  Router.route '/pubwifi/:_id', {
      name: 'wifiPubWifi'
      waitOn: ()->
        Session.set('wifiURLPage', this.params._id)
        Session.set('wifiOnlineId', this.params._id)
        [SubsManager.subscribe 'wifi', this.params._id,
         SubsManager.subscribe 'wifiPosts', this.params._id,
         SubsManager.subscribe 'wifiUsers', this.params._id,
         SubsManager.subscribe 'chatUsers', this.params._id]
      data: ()->
        Wifis.findOne {_id: this.params._id}
      action: ()->
        this.render()
      fastRender: true
    }

  Router.route '/scores/:_id', {
      name: 'scoresSubmitTips'
      waitOn: ()->
        Session.set('wifiOnlineId', this.params._id)
        [SubsManager.subscribe 'wifi', this.params._id]
      action: ()->
        this.render()
    }
  Router.route '/scores_form/:_id', {
      name: 'scoresSubmitForm'
      waitOn: ()->
        Session.set('wifiOnlineId', this.params._id)
        [SubsManager.subscribe 'wifi', this.params._id]
      action: ()->
        this.render()
    }

  Router.route '/index.html', {
      name: 'baoIndex'
      layoutTemplate: 'emptyLayout'
      action: ()->
        this.render()
    }

  Router.route '/welcome.html', {
      name: 'wuxianbaoWelcome'
      layoutTemplate: 'emptyLayout'
      action: ()->
        this.render()
    }

  Router.route '/wuxianbao/:mac_addr', {
      name: 'wuXianBao'
      waitOn: ()->
        console.log("this.params.mac_addr = "+JSON.stringify(this.params.mac_addr));
        [SubsManager.subscribe 'getWifiInfoBybssid', this.params.mac_addr]
        Session.set('wifiURLPage', this.params.mac_addr)
      action: ()->
        wifi = Wifis.findOne {BSSID: this.params.mac_addr}
        if wifi
          Session.set('wifiOnlineId', wifi._id)
        this.render()
      fastRender: true
    }

  Router.route '/wuxianbao/:mac_addr/gw_address/:gw_address/token/:token', {
      name: 'wuXianBaoWithToken'
      waitOn: ()->
        console.log("this.params.token = "+JSON.stringify(this.params.token))
        console.log("this.params.mac_addr = "+JSON.stringify(this.params.mac_addr))
        [SubsManager.subscribe 'getWifiInfoBybssid', this.params.mac_addr]
        Session.set('wifiGWAddress', this.params.gw_address)
        Session.set('wifiToken', this.params.token)
        Session.set('wifiURLPage', this.params.mac_addr)
      action: ()->
        wifi = Wifis.findOne {BSSID: this.params.mac_addr}
        if wifi
          Session.set('wifiOnlineId', wifi._id)
        this.render()
      fastRender: true
    }

  Router.route '/wuxianbaotest/:mac_addr/gw_address/:gw_address/token/:token', {
      name: 'wuXianBaoWithTokenTest'
      waitOn: ()->
        console.log("this.params.token = "+JSON.stringify(this.params.token))
        console.log("this.params.mac_addr = "+JSON.stringify(this.params.mac_addr))
        [SubsManager.subscribe 'getWifiInfoBybssid', this.params.mac_addr]
        Session.set('wifiGWAddress', this.params.gw_address)
        Session.set('wifiToken', this.params.token)
        Session.set('wifiURLPage', this.params.mac_addr)
        tags = document.getElementsByTagName('link')
        if tags.length > 0
          for i in [tags.length-1..0]
            href = tags[i].getAttribute('href')
            if tags[i] and href != null and href.charAt(0) is '/'
              console.log("link href = "+href)
              if href.indexOf('?') >= 0
                filename = href.replace(/^.*[\\\/]/, '').replace(/(.*)[\?]+.*/, "$1")
              else
                filename = href.replace(/^.*[\\\/]/, '')
              console.log("  link filename = "+filename)
              tags[i].parentNode.removeChild(tags[i])
              cssFile = document.createElement('link')
              cssFile.rel = 'stylesheet'
              cssFile.type = 'text/css'
              cssFile.href = 'http://'+this.params.gw_address+'/'+filename
              document.head.appendChild(cssFile)
        tags = document.getElementsByTagName('script')
        if tags.length > 0
          for i in [tags.length-1..0]
            if tags[i] and tags[i].getAttribute('src') != null and tags[i].getAttribute('src').charAt(0) is '/'
              console.log("js src = "+tags[i].getAttribute('src'))
              filename = tags[i].getAttribute('src').replace(/^.*[\\\/]/, '')
              console.log("  js filename = "+filename)
              tags[i].parentNode.removeChild(tags[i])
              jsFile = document.createElement('script')
              jsFile.type = 'text/javascript'
              jsFile.src = 'http://'+this.params.gw_address+'/'+filename
              document.head.appendChild(jsFile)
      action: ()->
        wifi = Wifis.findOne {BSSID: this.params.mac_addr}
        if wifi
          Session.set('wifiOnlineId', wifi._id)
        this.render()
      fastRender: true
    }

if Meteor.isServer
  Router.route '/pubwifi/:_id', {
      waitOn: ()->
        [SubsManager.subscribe 'wifi', this.params._id,
         SubsManager.subscribe 'wifiPosts', this.params._id,
         SubsManager.subscribe 'wifiUsers', this.params._id,
         SubsManager.subscribe 'chatUsers', this.params._id]
      fastRender: true
    }

  Router.route '/wuxianbao/:mac_addr', {
      waitOn: ()->
        [SubsManager.subscribe 'getWifiInfoBybssid', this.params.mac_addr]
      fastRender: true
    }

  Router.route '/wuxianbao/:mac_addr/gw_address/:gw_address/token/:token', {
      waitOn: ()->
        [SubsManager.subscribe 'getWifiInfoBybssid', this.params.mac_addr]
      fastRender: true
    }

  Router.route '/wuxianbaotest/:mac_addr/gw_address/:gw_address/token/:token', {
      waitOn: ()->
        [SubsManager.subscribe 'getWifiInfoBybssid', this.params.mac_addr]
      fastRender: true
    }
  Router.route('/clonebox/filestatus', {where: 'server'}).post( ()->
    data = this.request.body
    console.log('post request: ' + JSON.stringify(data))
    console.log("mac: " + data.mac + ", item: " + data.item)
    wifi = Wifis.findOne({BSSID:data.mac})
    if wifi != null and wifi != undefined and secureclonebox_user != null
      post = {
        userId: secureclonebox_user._id,
        userName: secureclonebox_user.profile.nike,
        userPicture: '/userPicture.png',
        text: 'SecureCloneBox file ' + data.item + ' synced successfully',
        createTime: new Date(),
        images: [],
        wifiID: wifi._id
      };
      WifiPosts.insert(post);
    this.response.end('processed\n');
  )

  TRAVELLER_SECURECLONEBOX = 'system-secureclonebox'
  secureclonebox_user = null
  checkCloneBoxAccount = ()->
    secureclonebox_user = Meteor.users.findOne({'username': TRAVELLER_SECURECLONEBOX})
    console.log("##RDBG checkCloneBoxAccount id: " + secureclonebox_user._id)

  Meteor.startup ->
    Meteor.setTimeout(checkCloneBoxAccount, 1000*5)
    ###
    WebApp.rawConnectHandlers.use("/wuxianbao", (req, res, next)->
        #res.setHeader('Content-type', 'application/javascript; charset=UTF-8')
        #res.write("http://192.168.98.254/test.js")
        #res.end()
        #res.setHeader('Cache-Control', 'no-cache')
        #res.setHeader('Expires', '0')
        #next()
    )
    WebApp.connectHandlers.use((req, res, next)->
        res.setHeader('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
        res.setHeader("Access-Control-Allow-Origin", "*")
        res.setHeader("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
        next()
    )
    ###
