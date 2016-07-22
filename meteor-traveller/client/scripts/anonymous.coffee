@AnonymousLogin = ()->  
  if(Meteor.isCordova)
    uuid = device.uuid
  else if(amplify.store('uuid'))
    uuid = amplify.store('uuid')
  else
    uuid = Meteor.uuid()
  
  Template.public_loading_index.__helpers.get('show')('登录中，请稍候...')
  Accounts.createUser(
    {
      username: uuid
      password: '123456'
      'profile':{
        nike: '匿名'
        picture: '/userPicture.png'
        anonymous: true
        browser: if Meteor.isCordova then false else true
      }
    }
    (err)->
      console.log('Registration Error is ' + JSON.stringify(err))
      if(!Meteor.isCordova)
        amplify.store('uuid', uuid)
      Meteor.loginWithPassword(uuid, '123456',(error)->
        Template.public_loading_index.__helpers.get('close')()
        if(!error)
          console.log('anonymous login.')
          safeUpdateDeviceWifi()
          if(window.updateMyOwnLocationAddress)
            window.updateMyOwnLocationAddress()
        else
          console.log('Login error is ' + JSON.stringify(error))
          PUB.toast('您的设备不支持匿名使用，请和我们联系')
        Session.set('view', 'dashboard')
      )
  )