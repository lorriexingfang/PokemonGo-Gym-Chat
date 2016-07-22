parseNoteContent = (htmlContent) ->
  ret = []
  console.log "parseNoteContent: " + htmlContent
  div = document.createElement("div")
  div.innerHTML = htmlContent  
  console.log 'child nodes length: ' + div.childNodes.length
  if (div.childNodes.length > 0)
    rt = div.childNodes[0]
    console.log 'root child length: ' + rt.childNodes.length
    i = 0
    while i < rt.childNodes.length
      if rt.childNodes[i].firstChild
        console.log "first child value: " + i + ": " + rt.childNodes[i].firstChild.nodeValue
        console.log "first child nodenmae: " + i + ": " + rt.childNodes[i].firstChild.nodeName
        if rt.childNodes[i].firstChild.nodeValue
          ret.push({is_txt: true, content: rt.childNodes[i].firstChild.nodeValue})
        else
          console.log("none text node name: " + rt.childNodes[i].firstChild.nodeName)
          console.log("src atrr: " + rt.childNodes[i].firstChild.attributes['src'].value)
          ret.push({is_txt: false, url: rt.childNodes[i].firstChild.attributes['src'].value})
      i++
  ret

imagesFromContents = (contents) ->
  images = []
  i = 0
  while i < contents.length
    images.push url: contents[i].url  unless contents[i].is_txt
    i++
  images

Template.notes_edit.rendered=->
  note_id = Session.get('view_data').note_id
  if note_id
    post = Posts.findOne(note_id)
    contents = parseNoteContent(post.html)
    Session.set("content_array", contents)
    upload_images = post.images;
    Session.set("upload_images", upload_images)
  else
    PUB.toast("no post id when editing post")

Template.notes_edit.helpers
  is_blackborad: ()->
    return Posts.findOne(Session.get('view_data').note_id).subtitle
  is_admin: ->
    Meteor.user().profile and Meteor.user().profile.isAdmin is 1
  page_title:->
    if Session.get('articleType') == 'ad'
      '编辑文章'
    else
      '编辑游记'
  title:->
    note_id = Session.get('view_data').note_id
    if note_id
      post = Posts.findOne(note_id)
      post.title
    else
      ''
  subtitle:->
    note_id = Session.get('view_data').note_id
    if note_id
      post = Posts.findOne(note_id)
      post.subtitle
    else
      ''
  contents:->
    Session.get "content_array"

Template.notes_edit.events
    "focus [name=content]":->
        $('#partner_activities .head').css('position', 'absolute')
    "blur [name=content]":->
        $('#partner_activities .head').css('position', 'fixed');
    "click #addtext":->
      contents = Session.get "content_array"
      contents.push({is_txt: true, content: ''})
      Session.set "content_array",contents
    "click .delete":(obj)->
      PUB.confirm(
        "你确定要删除吗？"
        ()->
          contents = Session.get "content_array"
          item = $(obj.currentTarget).prev()
          if item
            nm = item.prop('nodeName')
            if nm is 'IMG'
              src = item.attr('src')
              console.log("img clicked, src: " + src)
              idx = 0
              for i in contents
                if i.is_txt is false and i.url is src
                  console.log 'found img is_txt: ' + i.is_txt + ', url: ' + i.url
                  contents.splice(idx, 1)
                  Session.set 'content_array',contents
                  break
                idx++
            else if nm is 'TEXTAREA'
              txt = item.val()
              console.log 'TEXTAREA clicked, val: ' + txt
              idx = 0
              for i in contents
                if i.is_txt is true and i.content is txt
                  console.log 'found txt is_txt: ' + i.is_txt + ', url: ' + i.content
                  contents.splice(idx, 1)
                  Session.set 'content_array',contents
                  break;
                idx++
      )

    "click #addphoto":->
      uploadFile(
        (result)->
          $('#loading').css 'display','block'
          if result
            contents = Session.get "content_array"
            contents.push({is_txt: false, url: result})
            Session.set "content_array",contents
          $('#loading').css 'display','none'
        ,1
      )
        
    'click .leftButton': ->
#      PUB.back()
      window.page.back()
    
    'click .button_right': ->
      $(".add-notes-form").submit()
    
    'submit .add-notes-form': (e)->
      title = e.target.title.value
      content = "";
      console.log('title: ' + title)
      $("#content_dl  > dd").each (i,e)->
        if $(e).find(":first")[0].tagName is 'TEXTAREA'
          content+="<div style='padding:10px;'>" + $(e).find(":first").val() + "</div>"
        else if $(e).find(":first")[0].tagName is 'IMG'
          content+="<div style='padding:10px;'>" + '<img style="width:100%;" src="'+$(e).find(":first").attr("src")+'" />' + "</div>"
      console.log('content: ' + content)
      upload_images = imagesFromContents(Session.get('content_array'))
      console.log('upload_images: ' + JSON.stringify(upload_images))
      location = Session.get 'location'
      if location
        geometry = {type:"Point",coordinates:[location.longitude,location.latitude]} 
      else 
        geometry= {type:"Point",coordinates:[0,0]}
      console.log('geometry: ' + geometry)
      
      if(e.target.subtitle)
        if(e.target.subtitle.value is '')
          PUB.toast '简短描述不能为空！'
          return false
      
      if title is '' or content is ''
        PUB.toast '请填写完整！'
      else if upload_images.length <= 0 and Meteor.user().profile.isAdmin isnt 1
        PUB.toast '请至少上传一张图'
      else
        console.log("update, title: " + title + ", html: " + content + ", images: " + upload_images)
        post = {
          title: title
          html:  "<div style='padding:10px;'>" + content + "</div>"
          images: upload_images
          location: geometry
        }
        
        if(e.target.subtitle)
          post.subtitle = e.target.subtitle.value
        
        Posts.update(Session.get('view_data').note_id, {
          $set: post
        }, (error, affectedNum)->
          if error 
            PUB.toast '发布失败，请重试！'
          else
            PUB.back()
        )
      false