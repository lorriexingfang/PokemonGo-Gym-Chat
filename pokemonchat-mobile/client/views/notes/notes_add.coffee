Template.notes_add.rendered=->
  Session.set "upload_images", []
  
Template.notes_add.helpers
  is_blackborad: ()->
    Session.equals('notes_add_return', 'wifiReport')
  files: ->
    Session.get "upload_images"
  is_admin: ->
    Meteor.user().profile and Meteor.user().profile.isAdmin is 1
  title:->
    if Session.get('articleType') == 'ad'
      '写文章'
    else
      '发游记'
Template.notes_add.events
    "focus [name=content]":->
        $('#partner_activities .head').css('position', 'absolute')
    "blur [name=content]":->
        $('#partner_activities .head').css('position', 'fixed');
    "click #addtext":->
      $('#content_dl').append '<dd><textarea name="content" placeholder="游记内容..." style="width:90%;height:150px;" value=""></textarea><i class="fa fa-trash-o fa-3x delete" style="font-size:24px;color:#eb3941"></i></dd>'
    "click .delete":(obj)->
      PUB.confirm(
        "你确定要删除吗？"
        ()->
          upload_images = Session.get 'upload_images'
          imgs = $(obj.currentTarget).parent().find("img");
          if imgs.length > 0
            for i in upload_images
              if i.url == $(imgs[0]).attr("src")
                upload_images = upload_images.slice(0,_i).concat(upload_images.slice(_i+1,this.length));
                Session.set 'upload_images',upload_images
          $(obj.currentTarget).parent().remove();
      )

    "click #addphoto":->
      uploadFile(
        (result)->
          $('#loading').css 'display','block'
          if result
            upload_images = Session.get "upload_images"
            $('#content_dl').append '<dd><img style="width:90%;" src="'+result+'" /><i id="delete" class="fa fa-trash-o fa-3x delete" style="font-size:24px;color:#eb3941"></i></dd>'
            upload_images.push({url: result})
            Session.set "upload_images",upload_images
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
      $("#content_dl  > dd").each (i,e)->
        if $(e).find(":first")[0].tagName is 'TEXTAREA'
          content+="<div style='padding:10px;'>" + $(e).find(":first").val() + "</div>"
        else if $(e).find(":first")[0].tagName is 'IMG'
          content+="<div style='padding:10px;'>" + '<img style="width:100%;" src="'+$(e).find(":first").attr("src")+'" />' + "</div>"
        else
      upload_images = Session.get 'upload_images'
      location = Session.get 'location'
      if location
        geometry = {type:"Point",coordinates:[location.longitude,location.latitude]} 
      else 
        geometry= {type:"Point",coordinates:[0,0]}
        
      if(Session.equals('notes_add_return', 'wifiReport'))
        if(e.target.subtitle.value is '')
          PUB.toast '简短描述不能为空！'
          return false
      
      if title is '' or content is ''
        PUB.toast '请填写完整！'
      else if upload_images.length <= 0 and Meteor.user().profile.isAdmin isnt 1
        PUB.toast '请至少上传一张图'
      else
        articleType = Session.get('articleType')
        post = {
          type: articleType
          title: title
          titleImage: if Meteor.user().profile and Meteor.user().profile.isAdmin is 1 then {url: e.target.titleImage.value} else upload_images[0]
          #content: if Meteor.user().profile and Meteor.user().profile.isAdmin is 1 then undefined else content
          html:  "<div style='padding:10px;'>" + content + "</div>"
          images: upload_images
          userId: Meteor.user()._id
          userName: if Meteor.user().profile.nike is undefined or Meteor.user().profile.nike is "" then Meteor.user().username else Meteor.user().profile.nike
          userPicture: Meteor.user().profile.picture
          tags: [Session.get('tag')]
          order: if Session.equals('notes_add_return', 'wifiReport') then -1 else 0
          location: geometry
          createdAt: new Date() #current time
        }
        
        if(Session.equals('notes_add_return', 'wifiReport'))
          post.subtitle = e.target.subtitle.value

        Posts.insert post, (error, _id)->
          if error 
            PUB.toast '发布失败，请重试！'
          else if(Session.equals('notes_add_return', 'wifiReport'))
            window.wifiReportIng = true
            #在小黑板发表消息后会更新下wifi状态，沿用更新签名后会更改wifi状态实现方式
            Session.set('updateSignature', Session.get('updateSignature')+1)
            Meteor.users.update(
              {_id: Meteor.userId()}
              {
                $push: {
                  'business.reports': {
                    _id: (new Mongo.ObjectID())._str
                    userId: Meteor.userId()
                    userName: if Meteor.user().profile.nike then Meteor.user().profile.nike else if  Meteor.user().business.reports[0].userName then Meteor.user().business.reports[0].userName else Meteor.user().username
                    userPicture: if Meteor.user().profile.picture then Meteor.user().profile.picture else '/userPicture.png'
                    text: post.subtitle
                    title: post.title
                    articleId: _id
                    images: upload_images,
                    createTime: new Date()
                  }
                }
              }
              (err, number)->
                window.wifiReportIng = false
            )
            
            Session.set('notes_add_return', '')
            Session.set('view', 'wifiOnline')
          else
            PUB.back()
      false