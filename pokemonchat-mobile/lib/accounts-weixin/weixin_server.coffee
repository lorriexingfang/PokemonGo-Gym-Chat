if Meteor.isServer
  Accounts.registerLoginHandler 'weixin', (options)->
    if !options.weixin || !options.weixin.openid
      return undefined
    
    options.weixin.id = options.weixin.openid
    # console.log options
    Accounts.updateOrCreateUserFromExternalService(
      'weixin'
      options.weixin
      {
        profile:{
          nike: options.weixin.nickname
          uuid: options.device.uuid
          picture: options.weixin.headimgurl
          createdAt: new Date()
          sex: if options.weixin.sex is 1 then '男' else if options.weixin.sex is 2 then '女' else undefined
          city: options.device.city
          location: options.device.location
        }
      }
    )