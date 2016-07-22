Template.wifiReport.helpers
  is_manager: ()->
    return Session.equals('wifiOnlineId', Meteor.userId()) and Meteor.user().profile.isBusiness is 1
Template.wifiReport.events
  'click .tips': ()->
    Session.set('articleType', 'ad')
    Session.set('notes_add_return', Session.get('view'))
    PUB.page("notes_add", {tag: Session.get('tag')})
  'click .leftButton': ()->
    window.page.back()
  'click .rightButton': ()->
    $('.wifi-report-form').submit()
  'submit .wifi-report-form': (e)->
    upload_images = Template.public_upload_index.__helpers.get('images')();
    if(e.target.text.value is '' and upload_images.length == 0)
      PUB.toast('还没有输入任何内容哦~内容可以是文字或图片哦~')
    else
      #Template.public_loading_index.__helpers.get('show')('处理中，请稍候...');
      if(window.wifiReportIng == true)
        PUB.toast('正在提交请勿重复操作！')
      else
        window.wifiReportIng = true

        #在小黑板发表消息后会更新下wifi状态，沿用更新签名后会更改wifi状态实现方式
        Session.set('updateSignature', Session.get('updateSignature')+1)

        Meteor.users.update(
          {_id: Session.get('wifiOnlineId')}
          {
            $push: {
              'business.reports': {
                _id: (new Mongo.ObjectID())._str
                userId: Meteor.userId()
                userName: if Meteor.user().profile.nike then Meteor.user().profile.nike else if  Meteor.user().business.reports[0].userName then Meteor.user().business.reports[0].userName else Meteor.user().username
                userPicture: if Meteor.user().profile.picture then Meteor.user().profile.picture else '/userPicture.png'
                text: e.target.text.value
                images: upload_images,
                createTime: new Date()
              }
            }
          }
          (err, number)->
            #Template.public_loading_index.__helpers.get('close')();
            window.wifiReportIng = false
            if(err or number <= 0)
              PUB.toast('提交失败，请重试！')
            else
              Session.set('online-view', 'wifiOnlineReports')
              Session.set('view', 'wifiOnline')
        )

    false
