@loadImage = (url, params, callback)->
  img = new Image()
  img.src = url
  
  # 图片已经存在于浏览器缓存
  if(img.complete)
    callback.call(img, params)
  else
    img.onload = ()->
      callback.call(img, params)