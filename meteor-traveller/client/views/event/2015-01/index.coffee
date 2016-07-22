mobile = ''
Session.setDefault("event_2015_01_index_title", "")
Session.setDefault("event_2015_01_index_date", (new Date()).getFullYear()+'-'+((new Date()).getMonth()+1)+'-'+(new Date()).getDate())
Session.setDefault("event_2015_01_index_mobile", "")
Session.setDefault("event_2015_01_index_days", "1")
Session.setDefault("event_2015_01_index_intro", "")

Template.event_2015_01_index.rendered=->
  if Meteor.user().profile.city
    Session.set "userAddress",Meteor.user().profile.city
  else
    Session.set "userAddress",Session.get("city")

  geoc = new BMap.Geocoder()
  point = new BMap.Point(Session.get('location').longitude,Session.get('location').latitude)
  geoc.getLocation point,(rs)->
    if rs and rs.addressComponents
      addComp = rs.addressComponents
      if addComp.city and addComp.city isnt ''
        Session.set("userAddress",addComp.city+' '+addComp.district) #+' '+addComp.street)
    else
      requestUrl = "http://maps.googleapis.com/maps/api/geocode/json?latlng="+Session.get('location').latitude+','+Session.get('location').longitude+'&sensor=false'
      Meteor.http.call "GET",requestUrl,(error,result)->
        if result.statusCode is 200
          results = result.content.results
          Session.set("userAddress",JSON.stringify(result))
          
Template.event_2015_01_index.helpers
  event:->
    Events.findOne({eventNo: '2015-01'})
  is_valid: ->
    event = Events.findOne({eventNo: '2015-01'})
    now = new Date()
    
    if event is undefined
      return false
    if event.endDate is undefined
      return event.startDate <= now
    else
      return event.startDate <= now and event.endDate >= now
    
  files:->
    Template.public_upload_index.__helpers.get('images')()
  title:->
    Session.get "event_2015_01_index_title"
  date:->
    if Session.get("event_2015_01_index_date") is ''
      Session.set("event_2015_01_index_date", (new Date()).getFullYear()+'-'+((new Date()).getMonth()+1)+'-'+(new Date()).getDate())
    Session.get "event_2015_01_index_date"
  mobile:->
    Session.get "event_2015_01_index_mobile"
  days:->
    Session.get "event_2015_01_index_days"
  intro:->
    Session.get "event_2015_01_index_intro"
    
  is_not_mobile:->
    try
      if Meteor.user().profile.mobile.length is 11
        mobile = Meteor.user().profile.mobile
        return false
    catch
      mobile = ''
    true
    
Template.event_2015_01_index.events
  'click .leftButton': ->
    window.page.back()
    
  'change .form-control': (e)->
    Session.set("event_2015_01_index_#{e.currentTarget.id}", e.currentTarget.value)
    
  'change .intro': (e)->
    Session.set("event_2015_01_index_#{e.currentTarget.id}", e.currentTarget.value)
    
  'submit .event-form-add': (e)->
    if Meteor.user() is null
      Session.set("login_return_view",Session.get("view"))
      PUB.toast '请登录后发布!' 
      PUB.page("dashboard")
      return false

    city = Session.get("userAddress")
    title = e.target.title.value
    date = e.target.date.value
    days = e.target.days.value
    intro = e.target.intro.value
    tags = []
    location = Session.get('location')
    upload_images = Template.public_upload_index.__helpers.get('images')()
    geometry = null
      
    if e.target.mobile isnt undefined
      if e.target.mobile.value isnt ''
        mobile = e.target.mobile.value
    
    if mobile.length isnt 11
      PUB.toast('手机号码格式不对！')
      return false

    if (upload_images is undefined or upload_images.length <= 0) and Meteor.isCordova
      PUB.toast('请至少上传一张图片！')
      return false
    
    if title is '' or date is '' or days is '' or intro is '' or mobile is ''
      PUB.toast('请完整填写表单！')
      return false
    
    if isNaN(parseInt(days))
      PUB.toast('旅游天数必需为整数！')
      return false
    
#    if intro.indexOf("#免费客栈#") is -1
#      intro += '#免费客栈#'
    
    if location isnt undefined
      geometry = {type:"Point",coordinates:[location.longitude,location.latitude]}
    else
      geometry = {type:"Point",coordinates:[0,0]}

    Tags.find({}).forEach (t)->
      if (title+intro).indexOf(t.tag) isnt -1
        tags.push({id:t._id,tag:t.tag})
        
    try
      userPicture = Meteor.user().profile.picture
    catch e
      userPicture = null
      
    registrationID = Session.get('registrationID')
    registrationType = Session.get( 'registrationType')
    tokenInfo = {type:registrationType,token:registrationID}
    
    if mobile.length is 11
      Meteor.users.update(
        {_id: Meteor.userId()}
        {
          $set: {'profile.mobile': mobile}
        }
      )
    
    Posts.insert {
      type: 'pub_board'
      title:title
      text: intro
      startDate:date #出发日期
      days:days #去几天
      good: 0
      views:[] #浏览人
      toJoin:[] #加入的人
      replys:[] #评论
      reports:[] #举报
      report: 0 #举报数量
      token: tokenInfo
      tags:tags
      images: upload_images
      userId: Meteor.userId()
      name: Meteor.user().profile.nike
      nike: Meteor.user().profile.nike
      userPicture: userPicture
      city: city
      isCustomCity: false
      location: geometry
      createdAt: new Date()
      events: [{eventNo: '2015-01'}]
    }, (error, _id)->
      console.log "Posts insert _id is " + _id
      for item in upload_images
        Photos.insert {
          userId: Meteor.userId()
          createAt: new Date()
          postId: _id
          imageUrl: item.url
        }
    
    Session.set("event_2015_01_index_title", "")
    Session.set("event_2015_01_index_date", '')
    Session.set("event_2015_01_index_mobile", "")
    Session.set("event_2015_01_index_days", "1")
    Session.set("event_2015_01_index_intro", "")
    Template.public_upload_index.__helpers.get('reset')()
    Session.set("view", "partner")
    return false
    
  'click .fa-photo':->
    uploadFile (result)->
      if result
        upload_images = Session.get "event_2015_01_index_upload_images"
        upload_images.push({url: result})
        Session.set "event_2015_01_index_upload_images",upload_images