Template.wifiPubwifiPasswd.events
  'click #btn_back': ()->
    window.page.back()
  'click .btn-submit': (e)->
    window.page.back()
    passwd = $('#wifi_passwd').val()

    Wifis.update(
        {_id: Session.get('wifiOnlineId')}
        {$set: {'passwd': passwd}}
        (err, number)->
          if(err or number <= 0)
                PUB.toast('修改密码失败，请重试！');
    )

Template.wifiPubwifiPasswd.helpers
  'oldPasswd':()->
      return Session.get('myWifiPubwifiPasswd')