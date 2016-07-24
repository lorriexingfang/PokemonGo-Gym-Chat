class chatUploadImage
  _images = []
    
  _add_image = (image)->
    $msg_box = $('#message-box #remark')
    $msg_box_ul = $msg_box.find('#'+image.id)
    if($msg_box_ul.length <= 0)
      if(image.status is 'error')
        html = '<ul class="upload upload-error" id="'+image.id+'">'
      else
        html = '<ul class="upload upload-wait" id="'+image.id+'">'
      html += '<li class="r">'
      html += '<div class="faceimg"><img src="'+Meteor.user().profile.picture+'" width="50" height="50"/></div>'
      html += '<div class="comment">'
      html += '<div class="upload-bar">'
      html += '<img class="lazy chatimg" height="100px" src="'+image.url+'">'
      html += '<div class="mask"></div>'
      html += '<div class="tips"><i class="fa fa-refresh fa-spin"></i>0%</div>'
      html += '</div>'
      html += '</div>'
      html += '</li>'
      html += '<div class="clear"></div>'
      html += '</ul>'
      $msg_box.append(html)
      chatMessages = $('#chat #message-box')
      chatMessages.get(0).scrollTop = chatMessages.get(0).scrollHeight+99999
    
  _update_image = (image)->
    $msg_box = $('#message-box #remark')
    $msg_box_ul = $msg_box.find('#'+image.id)
    if($msg_box_ul.length > 0)
      html = '<li class="r">'
      html += '<div class="faceimg"><img src="'+Meteor.user().profile.picture+'" width="50" height="50"/></div>'
      html += '<div class="comment">'
      html += '<div class="upload-bar">'
      html += '<img class="lazy chatimg" height="100px" src="'+image.url+'">'
      html += '<div class="mask"></div>'
      html += '<div class="tips"><i class="fa fa-refresh fa-spin"></i>'+image.percentage+'%</div>'
      html += '</div>'
      html += '</div>'
      html += '</li>'
      html += '<div class="clear"></div>'
      $msg_box_ul.html(html)
      $msg_box_ul.removeClass()
      if(image.status is 'error')
        $msg_box_ul.addClass('upload-error')
      else
        $msg_box_ul.addClass('upload-wait')
    else
      _add_image(image)
  
  _update_image2 = (image)->
    DEBUG && console.log("image.percentage="+image.percentage)
    $('#'+image.id+' div.tips').html('<i class="fa fa-refresh fa-spin"></i>' + image.percentage+'%')

  _remove_image = (id)->
    $('#message-box #remark #'+id).remove()
    
  _upload = (image, callback)->    
    #_add_image(image)
    image.callback = callback
    image.upload = ()->
      image.status = 'uploading'
      multiThreadUploadFile_new(
        [image], 1
        (err, result)->
          DEBUG && console.log('multiThreadUploadFile_new result: ' + JSON.stringify(result))
          if(_images.length <= 0)
            return
          
          for i in [0.._images.length-1]
            if(_images[i].id is result[0].id)
              if(err)
                DEBUG && console.log("multiThreadUploadFile, failed")
                _images[i].status = 'error'
                #_update_image(_images[i])
                _update_image2(_images[i])
              else
                _images[i].url = result[0].url
                if _images[i].callback?
                  _images[i].callback(_images[i])
                _images.splice(i, 1)
                #_remove_image(result[0].id)
              break
        (result, progress)->
          DEBUG && console.log('multiThreadUploadFile_new progress result: ' + JSON.stringify(result))
          if(_images.length <= 0)
            return
          
          for i in [0.._images.length-1]
            if(_images[i].id is result.id)
              _images[i].percentage = progress
              #_update_image(_images[i])
              _update_image2(_images[i])
              break
      )
      
    _images.push(image)
    DEBUG && console.log('selected image: '+ JSON.stringify(image))
    image.upload()
    
  test: (callback)->
    image = {id: (new Mongo.ObjectID())._str, userId: Session.get("chat_to_userId"), url:'http://localhost.com/sywFzQ5sDbKEF4PQk_1442975583590_Temp_timg33-501911568.bin', filename:'', URI:''}
    callback(image)
    
  upload: (max_number, userId, callback, completedCallback)->
#    this.test(callback)
#    return
#    
    self = this
    selectMediaFromAblum(max_number, (cancel, result, currentCount,totalCount)->
      DEBUG && console.log("upload")
      if (cancel)
        return
      if (result)
        image = {id: (new Mongo.ObjectID())._str, userId: userId, url:result.smallImage, filename:result.filename, URI:result.URI, percentage:0}
        callback(image)
        _upload(image, completedCallback)
    )

  refresh: (userId)->
    if(_images.length <= 0)
      return
    for i in [0.._images.length-1]
      if (_images[i].userId is userId)
        _update_image(_images[i])
    
  reUpload: (id)->
    if(_images.length <= 0)
      return
    for i in [0.._images.length-1]
      if (_images[i].id is id)
        _images[i].upload()
        break
    
  cancelUploadImage: (id)->
    DEBUG && console.log('cancelUploadImage: ' + id)
    if(_images.length <= 0)
      return
    for i in [0.._images.length-1]
      if (_images[i].id is id)
        DEBUG && console.log('cancelUploadImage: ' + JSON.stringify(_images[i]))
        _images.splice(i, 1)
        #_remove_image(id)
        break
    
@ChatUploadImage = new chatUploadImage()