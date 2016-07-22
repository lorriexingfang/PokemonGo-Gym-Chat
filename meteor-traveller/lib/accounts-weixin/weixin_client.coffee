if Meteor.isClient
  Meteor.loginWithWeixin = (callback)->       
    WechatOauth.getUserInfo(
      {}
      (e)->
        options = {
          device: {
            uuid: Session.get("uuid")
            city: Session.get("location_city")
            location: Session.get("location")
            time: new Date() # 防止以上字段为空时，device为空
          }
          weixin: e
#          weixin: {
#            sex: 1
#            nickname: "xxxxx"
#            unionid: "om4Tytz9Bkt4K3mUaTqr0QQpDdhY"
#            privilege: []
#            province: "Yunnan"
#            openid: "o9qD-tk4MvPDUqDsCQpAv20QGA-Y"
#            language: "zh_CN"
#            headimgurl: "http://wx.qlogo.cn/mmopen/Vk4JzN9VHviaN1VyyrdSB1PBKtIoqgkzOFmob6JqFiaO6Jt7vQeqWRcukKPWIpJa7FZW3mk2ErctHG6HEj2otJFmiaBBiaicoyOVE/0"
#            country: "CN"
#            city: "Kunming"
#          }
        }
        # console.log options

        Accounts.callLoginMethod(
          methodArguments: [options]
          userCallback: (err, result)->
            if err
              callback(err)
            else
              callback(null, result)
        )
      ()->
        callback("The Weixin logon failure.")
    )