Template.public_upload_index.helpers
  images: ->
    Session.get("public_upload_index_images") || []
    
  reset: ->
    Session.set("public_upload_index_images", [])

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
    uploadNewTakenPhoto(()->).done((value)->
      images = Session.get("public_upload_index_images") || []
      if value.length > 0
        for item in value
          images.push(item)
        console.log 'images is: ' + JSON.stringify(images)
        Session.set("public_upload_index_images", images)
        
      # t.$('.camera').html('<i class="fa fa-camera"></i>拍照上传')
      # t.$('.add').html('<i class="fa fa-plus"></i>本地上传')
      t.$('.camera').html('<img src="camera-icon.png" alt="拍照上传"/>')
      t.$('.add').html('<img src="plus-icon.png" alt="本地上传"/>')
    ).fail((err)->
      # t.$('.camera').html('<i class="fa fa-camera"></i>拍照上传')
      # t.$('.add').html('<i class="fa fa-plus"></i>本地上传') ###
      t.$('.camera').html('<img src="camera-icon.png" alt="拍照上传"/>')
      t.$('.add').html('<img src="plus-icon.png" alt="本地上传"/>')
      PUB.toast("上传失败！")
    )    
      
  'click .add': (e, t)->
    # images = Session.get("public_upload_index_images") || []
    # images.push({url: 'a.png'})
    # Session.set("public_upload_index_images", images)
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