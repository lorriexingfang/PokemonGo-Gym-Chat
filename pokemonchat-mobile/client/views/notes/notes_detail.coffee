Template.notes_detail.helpers
  post:->
    Posts.findOne {_id: this.id}
  time_diff: (created)->
    now = new Date();
    GetTime0(now - created);
  show_good: (good)->
    if good then good else 0
  titleName:->
    if Session.get('articleType') == 'ad'
      '文章详情'
    else
      '游记详情'
Template.notes_detail.events
    'click .leftButton': ->
#      PUB.back()
      window.page.back()
    "click .image_view img": (e)->
      post = Posts.findOne {_id: Session.get("view_data").id}
      images = new Array()
      post.images.forEach (item)->
        images.push item.url
      Session.set "images_view_images", images
      Session.set "images_view_images_selected", e.currentTarget.src
      PUB.page("images_view")
      Meteor.setTimeout ->
        Session.set "cancelBubble", false
        300