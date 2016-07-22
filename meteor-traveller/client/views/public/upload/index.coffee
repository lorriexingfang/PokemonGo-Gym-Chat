Template.public_upload_index.helpers
  images: ->
    Session.get("public_upload_index_images") || []
    
  reset: ->
    Session.set("public_upload_index_images", [])

  uploadImages: (callback)->
    images = Session.get("public_upload_index_images") || []
    if images.length <= 0
      return
    imagesToBeUploaded = []
    for i in [0..(images.length-1)]
      if images[i].url.toLowerCase().indexOf("http://")>= 0 or images[i].url.toLowerCase().indexOf("https://")>= 0
        continue
      imagesToBeUploaded.push(images[i])
    if (imagesToBeUploaded.length > 0)
        Session.set('terminateUpload', false)
        multiThreadUploadFileWhenPublishInCordova(imagesToBeUploaded, (err, result)->
          if result?
              for i in [0..(result.length-1)]
                if result[i].uploaded and result[i]._id and result[i].url
                  for j in [0..(images.length-1)]
                    if images[j].filename is result[i].filename
                      images[j].url = result[i].url
                      console.log("update url to "+images[j].url)
                      break
              Session.set("public_upload_index_images", images)
          if err and result
            callback(false)
          else
            callback(true)
        )
    else
        callback(true)

Template.public_upload_index.events
  'click .delete': (e)->
    img = $(e.currentTarget).parent().find("img").attr("src")
    images = Session.get("public_upload_index_images") || []
    
    if images.length > 0
      PUB.confirm(
        "确定要删除此图片吗？"
        ()->
          for i in [0..images.length-1]
            if images[i].url is img
              images.splice(i, 1)
              break

          Session.set("public_upload_index_images", images)
      )
  
  'click .camera': (e, t)->
    console.log 'click the camera button'
    takePictureFromCamera((cancel, result)->
      if cancel
        t.$('.camera').html('<img src="camera-icon.png" alt="拍照上传"/>')
        t.$('.add').html('<img src="plus-icon.png" alt="本地上传"/>')
      else
        console.log 'take picture result: ' + JSON.stringify(result)
        images = Session.get("public_upload_index_images") || []
        image = {url:result.smallImage, filename:result.filename, URI:result.URI}
        images.push(image)
        console.log 'images is: ' + JSON.stringify(images)
        Session.set("public_upload_index_images", images)
    )
#    uploadNewTakenPhoto(()->).done((value)->
#      images = Session.get("public_upload_index_images") || []
#      if value.length > 0
#        for item in value
#          images.push(item)
#        console.log 'images is: ' + JSON.stringify(images)
#        Session.set("public_upload_index_images", images)
#        
#      # t.$('.camera').html('<i class="fa fa-camera"></i>拍照上传')
#      # t.$('.add').html('<i class="fa fa-plus"></i>本地上传')
#      t.$('.camera').html('<img src="camera-icon.png" alt="拍照上传"/>')
#      t.$('.add').html('<img src="plus-icon.png" alt="本地上传"/>')
#    ).fail((err)->
#      # t.$('.camera').html('<i class="fa fa-camera"></i>拍照上传')
#      # t.$('.add').html('<i class="fa fa-plus"></i>本地上传') ###
#      t.$('.camera').html('<img src="camera-icon.png" alt="拍照上传"/>')
#      t.$('.add').html('<img src="plus-icon.png" alt="本地上传"/>')
#      PUB.toast("上传失败！")
#    )    
      
  'click .add': (e, t)->
    # images = Session.get("public_upload_index_images") || []
    # images.push({url: 'a.png'})
    # Session.set("public_upload_index_images", images)
    selectMediaFromAblum(9, (cancel, result,currentCount,totalCount)->
      if cancel
        t.$('.camera').html('<img src="camera-icon.png" alt="拍照上传"/>')
        t.$('.add').html('<img src="plus-icon.png" alt="本地上传"/>')
        return
      if result
        console.log 'Local is ' + result.smallImage
        images = Session.get("public_upload_index_images") || []
        image = {url:result.smallImage, filename:result.filename, URI:result.URI}
        images.push(image)
        console.log 'images is: ' + JSON.stringify(images)
        Session.set("public_upload_index_images", images)
        t.$('.camera').html('<img src="camera-icon.png" alt="拍照上传"/>')
        t.$('.add').html('<img src="plus-icon.png" alt="本地上传"/>')
        #if currentCount >= totalCount
        #  Meteor.setTimeout(()->
        #    Template.addPost.__helpers.get('saveDraft')()
        #  ,100)
    )
    ###
   uploadFile(()->).done((value)->
     images = Session.get("public_upload_index_images") || []
     if value.length > 0
       for item in value
         images.push(item)
       console.log 'images is: ' + JSON.stringify(images)
       Session.set("public_upload_index_images", images)
       t.$('.camera').html('<img src="camera-icon.png" alt="拍照上传"/>')
       t.$('.add').html('<img src="plus-icon.png" alt="本地上传"/>')
   ).fail((err)->
     t.$('.camera').html('<img src="camera-icon.png" alt="拍照上传"/>')
     t.$('.add').html('<img src="plus-icon.png" alt="本地上传"/>')
     PUB.toast("上传失败！")
   )
    ###