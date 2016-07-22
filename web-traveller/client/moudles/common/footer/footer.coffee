Template.footer.events
  #'click .download': ()->
    #window.location = 'http://server2.youzhadahuo.com:8080/download.html'
  'click .download .ios': ()->
    window.location = 'https://itunes.apple.com/cn/app/id1058218641'
  'click .download .android': ()->
    window.location = 'http://app.qq.com/#id=detail&appid=1105002882'
  'click .downloadAPP': ()->
    is_weixn=()->
      ua = navigator.userAgent.toLowerCase()
      if ua.match(/MicroMessenger/i) is "micromessenger"
        true
      else
        false
    if is_weixn()
      PUB.toast('由于微信进行了限制，请使用浏览器打开后下载本APP。')
      #return
    u = navigator.userAgent
    isAndroid = u.indexOf('Android') > -1               #android
    isiOS = !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/)  #ios
    if !isiOS and !isAndroid
      PUB.toast('很抱歉，您使用的平台不支持。目前仅支持iPhone或Android用户下载APP。')
      #return
    $.ajax({
        url: "http://192.168.1.1/cgi-bin/cgi_ip",
        type: 'POST',
        #data: 'username=admin&password=admin1',
        dataType: 'json',
        success: (response)->
            PUB.toast('授权成功！正在转到APP下载页面...')
            if isAndroid
              window.location = 'http://app.qq.com/#id=detail&appid=1105002882'
            else if isiOS
              window.location = 'https://itunes.apple.com/cn/app/id1058218641'
        ,
        error: (err)->
            PUB.toast('授权失败！')
    })
  'click .accessInternet': ()->
    PUB.toast('正在授权访问因特网...')
    $.ajax({
        url: "http://192.168.1.1/cgi-bin/cgi_ip",
        type: 'POST',
        #data: 'username=admin&password=admin1',
        dataType: 'json',
        success: (response)->
            PUB.toast('授权成功！')
        ,
        error: (err)->
            PUB.toast('授权失败！')
    })