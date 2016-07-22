root = exports ? this

Router.route(
  '/post/:_id'
  name: 'post.detail'
#  waitOn: ()->
#    Meteor.subscribe 'postOne', this.params._id
  data: ()->
    Posts.findOne {_id: this.params._id} 
  action: ()->
    Session.set('post_id', this.params._id)
    SubsManager.subscribe('postOne', this.params._id)
    this.render()
)

Template.postDetail.helpers
  time_diff: (created)->
    now = new Date()
    GetTime0(now - created)
    
  format_day:(day, n)->
    today = new Date(day)
    today.setDate(today.getDate() + Math.abs(n))
    day+' ~ '+today.getFullYear()+"-"+(today.getMonth()+1)+"-"+today.getDate()
  
  is_local: (type)->
    type is 'local_service'
    
  is_partner: (type)->
    type is 'pub_board'
  
  is_reply: (obj)->
    obj.length > 0
  
  limit_num: (num, v)->
    if (v.length > num)
        v.slice(0, num)
    else
        v

Template.postDetail.events
  'click .image img': (e)->
    images = new Array()
    selected = ''
    imgs = Posts.findOne({_id: Session.get('post_id')}).images
    for item in imgs
      images.push(item.url)
      if(item.url is e.currentTarget.src)
        selected = item.url

    Session.set("images_view_images", images)
    Session.set("images_view_images_selected", selected)
    Template.imagesView.__helpers.get('show')()
    #Router.go('/swipeView')