Template.scoresSubmitTips.events({
  'click .leftButton': function(){
    window.page.back();
  },
  'click button': function(){
    Session.set('dialogView', 'scoresSubmitForm');
  }
});

Template.scoresSubmitForm.onRendered(function(){
  Template.public_upload_index.__helpers.get('reset')();
});
Template.scoresSubmitForm.onDestroyed(function(){
  Template.public_upload_index.__helpers.get('reset')();
});
Template.scoresSubmitForm.events({
  'click .leftButton': function(){
    window.page.back();
  },
  'click .scores-submit-form-submit': function(e, t){
    return t.$('.scores-submit-form').submit();
  },
  'submit .scores-submit-form': function(e, t){
    if (!t.$(e.target.type).val() || t.$('.scores-submit-form-submit').text() === '正在处理...')
      return false;
    
    var type = t.$(e.target.type).val();
    var amount = t.$(e.target.amount).val();
    var remark = t.$(e.target.remark).val();
    var images = Template.public_upload_index.__helpers.get('images')() || [];
    
    if(type === 'consume' && amount === ''){
      PUB.toast('消费金额不能为空~');
    }else if(images.length <= 0){
      PUB.toast('请上传相对应的图片凭证~');
    }
    else{
      t.$('.scores-submit-form-submit').text('正在处理...');
      Template.public_upload_index.__helpers.get('uploadImages')(function(result){
        if (result === true){
          images = Template.public_upload_index.__helpers.get('images')() || [];
          Scores.insert({
            type: type,
            amount: amount,
            remark: remark,
            images: images,
            userId: Meteor.userId(),
            userName: Meteor.user().profile.nike ? Meteor.user().profile.nike : '无名用户',
            userPicture: Meteor.user().profile.picture ? Meteor.user().profile.picture : '/userPicture.png',
            wifiId: Session.get('wifiOnlineId'), //Wifis.findOne({'_id': Session.get('wifiOnlineId')}),
            createdAt: new Date()
          }, function(error, _id){
            if (error)
              PUB.toast('提交失败，请重试~');
            else
              if(Session.equals('isDialogView', true)){
                Session.set('isDialogView', false);
              }else{
                Session.set('wifiPubWifi-view', 'wifiPubWifiIndex');
                Session.set('view', 'wifiPubWifi');
              }
            t.$('.scores-submit-form-submit').text('确定提交');
            trackEvent("提交积分", "Some on commit the a score record.");
          });
        }else{
          PUB.toast('上传图片失败，请重试~');
          t.$('.scores-submit-form-submit').text('确定提交');
        }
      });
    }
    
    return false;
  }
});