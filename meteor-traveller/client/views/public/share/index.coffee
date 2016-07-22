public_share = null

Template.public_share_index.helpers
  show: ()->
    if public_share is null
      public_share = Blaze.render Template.public_share_index, document.body
      if device.platform is 'Android'
        $("#weixin-sc").css("visibility","visible");
        $("#qq").css("visibility","visible");
        $("#qzone").css("visibility","visible");
        $("#weibo").css("visibility","visible");
      else
        $("#weixin-sc").css("visibility","hidden");
        $("#qq").css("visibility","hidden");
        $("#qzone").css("visibility","hidden");
        $("#weibo").css("visibility","hidden");
  close: ()->
    if public_share isnt null
      Blaze.remove public_share
      public_share = null

Template.public_share_index.events
  'click .share-box li': (e)->
    Template.public_share_index.__helpers.get('close')()
    obj = Posts.findOne({_id: Session.get('partnerId')})
    imagesUrl = [];
    image_url = "";
    if obj.images isnt undefined and obj.images.length >0
      imagesUrl.push num.url for num in obj.images
    if imagesUrl.length > 0
      image_url = imagesUrl[0]
    console.log obj.text
    param = {
      "title": "小店公告",
      "summary": obj.text,
      "image_url":image_url,
      "target_url": "http://share.youzhadahuo.com:443/post/"+obj._id
    }
    switch e.currentTarget.id
      when 'weixin'
        if device.platform is 'Android'
          WechatShare.shareToSession(
            param
            (e)->
              alert('ok')
            (e)->
              alert('err')
          )
        else
          WechatShare.share({scene:1,message:{title: param.title,description: param.summary,thumbData:param.image_url,url: param.target_url}},()-> return,
          ()-> return)
      when 'weixin-pyq'
        param.title = param.summary;
        if device.platform is 'Android'
          WechatShare.shareToMoment param,(e)->return,
          (e)->return
        else
          WechatShare.share({scene:2,message:{title: param.title,description: param.summary,thumbData:param.image_url,url: param.target_url}},()-> return,
          ()-> return)
      when 'weixin-sc'
        WechatShare.shareToFavorite param,(e)->return,
        (e)->return
      when 'qq'
        param.appid="1103491087";
        TencentShare.qqShare param,(e)->return,
        (e)->return
      when 'qzone'
        param.appid="1103491087";
        TencentShare.qzoneShare param,(e)->return,
        (e)->return
      when 'weibo'
        WeiboShare.share param,(e)->return,
        (e)->return
  'click .close-btn': ()->
    Template.public_share_index.__helpers.get('close')()
