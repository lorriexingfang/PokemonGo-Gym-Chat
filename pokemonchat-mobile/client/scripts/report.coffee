#SPACE 2 @Tim
Template.report.helpers
  post:->
    Posts.findOne({_id: Session.get('reportPostId')})

Template.report.events 
  "click #btn_back":->
    PUB.back()
  "click #btn_submit":->
    if Meteor.user() is null #登录
      PUB.toast '请先登录！'
      PUB.page("dashboard")
      false
    else
      reportReason = $('#report_reason').val()
      reports = []
      try
        reports = Posts.findOne({_id: Session.get("reportPostId")}).reports
      catch error
        reports = []
      if reportReason is '' #举报内容为空
#        window.plugins.toast.showLongBottom('请填写举报内容！')
        PUB.toast '请填写举报内容！'
      else if reports is undefined #旧数据无reports
        try
          Posts.update {
            _id: Session.get("reportPostId"),
          }, {
            $push: {
                reports: {
                  userId : Meteor.user()._id
                  reason: $('#report_reason').val()
                  createdAt: new Date()
                }
            }
          }
          Posts.update {_id: Session.get("reportPostId")},{$set: {report:1}}
        catch error
          console.log error
        PUB.toast '已提交审核！'
        PUB.back()
      else if JSON.stringify(reports).indexOf(Meteor.userId()) is -1 #之前未举报
        reports.sort()
        reports.push {userId: Meteor.userId(),reason: $('#report_reason').val(),createdAt: new Date()}
        Posts.update {_id: Session.get("reportPostId")},{$set: {reports: reports},$inc: {report:1}}
        PUB.toast '已提交审核！'
        PUB.back()
      else
        PUB.toast '您已举报过，正在审核！'
        PUB.back()
        
Template.reportList.rendered=->
  $('#'+Session.get('rview')).css 'border-bottom','2px solid #00a1e9'
        
Template.reportList.events 
  "click #btn_back":->
    PUB.back()
  'click .btn-group-justified .btn-group':(e)->
    $('.btn-group').css 'border-bottom','none'
    $('#'+e.currentTarget.id).css 'border-bottom','2px solid #00a1e9'
    Session.set 'rview',e.currentTarget.id

Template.reportList.helpers
  rview:->
    Session.get 'rview'

Template.partnerReport.helpers 
  lists:->
    Posts.find({type: 'pub_board',}, {sort: {report: -1},limit:50})
    
Template.localReport.helpers 
  lists:->
    Posts.find({type: 'local_service'}, {sort: {report: -1},limit:50})
    
Template.reason.helpers 
  post:->
    Posts.findOne({_id: Session.get('reportPostId')})
  report:->
    Posts.findOne({_id: Session.get('reportPostId')}).reports
  get_face:(uid)->
    if Meteor.users.findOne(uid) and Meteor.users.findOne(uid).profile and Meteor.users.findOne(uid).profile.picture then Meteor.users.findOne(uid).profile.picture
  get_name:(uid)->
    if Meteor.users.findOne(uid) and Meteor.users.findOne(uid).profile and Meteor.users.findOne(uid).profile.nike then Meteor.users.findOne(uid).profile.nike else '无名'
  format_day:(today)->
    today.getFullYear()+"-"+(today.getMonth()+1)+"-"+today.getDate()
      
Template.reason.events
  "click #btn_back":->
    PUB.back()
    