@FullScreenShowWifiPhotos = (images, selectedImage, wifiID, loadedPhotosCnt, photosCnt, loadedCreateTime)->
    Session.set("images_view_images", images)
    Session.set("images_view_images_loadedcount", loadedPhotosCnt);
    Session.set('images_view_images_loadedCreateTime', loadedCreateTime)
    Session.set("images_view_images_selected", selectedImage)
    Session.set("return_view", Session.get("view"))
    Session.set("document.body.scrollTop", document.body.scrollTop)
    Session.set('wifi_wifiPhotos_limit', 0)
    
    Tracker.autorun(()->
      loadedCount = Session.get('images_view_images_loadedcount')
      loadedTime = Session.get('images_view_images_loadedCreateTime')
      wifiPhotos = WifiPhotos.find({wifiID:wifiID, 'createTime':{$lt:loadedTime}}, {sort:{createTime:-1}}).fetch()
      console.log("autorun: loadedCount="+loadedCount+", wifiPhotos.length="+wifiPhotos.length)
      if wifiPhotos.length > 0
        images = Session.get("images_view_images")
        console.log("images.length="+images.length+", loadedCount="+loadedCount+", wifiPhotos.length="+wifiPhotos.length)
        if images.length < photosCnt and images.length-loadedCount-2 >= 0  #We have a deafult photo at the last index "fullscreenloading.png" 
          for i in [images.length-loadedCount-2..wifiPhotos.length-1]
            if loadedCount+i < images.length
              images[loadedCount+i] = wifiPhotos[i].url
            else
              images.push(wifiPhotos[i].url)
        if images.length < photosCnt
          images.push('/fullscreenloading.png') #lazy-loading-70.gif
        Session.set("images_view_images", images)
        #Session.set("images_view_images_loadedcount", images.length)
        #Session.set('images_view_images_loadedCreateTime', wifiPhotos[wifiPhotos.length-1].createTime)
    )
    PUB.page("images_view",  {imageCount:photosCnt, callback:(activeIndex)->
      console.log("activeIndex="+activeIndex+", "+Session.get("images_view_images").length)
      if activeIndex is null or activeIndex is undefined
        return
      #$('#wrap2 .swiper-slide a img').css 'width',$(window).width()+'px'
      console.log("wifi_wifiPhotos_limit="+Session.get('wifi_wifiPhotos_limit'))
      if activeIndex + 3 >= Session.get("images_view_images").length
        limit = Session.get('wifi_wifiPhotos_limit')+2
        Session.set('wifi_wifiPhotos_limit', limit)
        customSubscribe('wifiPhotosLimit', Session.get('wifiOnlineId'), limit, Session.get('images_view_images_loadedCreateTime'))
    })

