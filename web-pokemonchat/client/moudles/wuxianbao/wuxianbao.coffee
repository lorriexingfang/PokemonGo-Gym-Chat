Template.baoIndex.onRendered ()->
    $.ajax({
        url: "http://192.168.1.1/cgi-bin/cgi_mac",
        type: 'POST',
        crossOrigin: true,
        #data: 'username=admin&password=admin1',
        dataType: 'jsonp',
        success: (response)->
          console.log('response = '+response)
          window.location = 'http://server2.youzhadahuo.com/wuxianbao/'+response
        ,
        error: (err)->
            PUB.toast('连接失败，请重试一次。')
    })

Template.wuXianBao.helpers
    getMacAddress: ()->
      return Session.get('wifiBSSID')
    getBlackboardURL: ()->
      wifi = Wifis.findOne({'BSSID': Session.get('wifiBSSID')})
      return 'http://server2.youzhadahuo.com:443/pubwifi/' + wifi._id