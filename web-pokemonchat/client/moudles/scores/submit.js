Template.scoresSubmitTips.events({
  'click .leftButton': function(){
    history.go(-1);
  },
  'click button': function(){
    Router.go('scoresSubmitForm', {_id: Session.get('wifiOnlineId')});
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
    history.go(-1);
  },
  'click .scores-submit-form-submit': function(e, t){
    return t.$('.scores-submit-form').submit();
  },
  'submit .scores-submit-form': function(e, t){
    if (!t.$(e.target.type).val())
      return false;
    
    var type = t.$(e.target.type).val();
    var amount = t.$(e.target.amount).val();
    var remark = t.$(e.target.remark).val();
    //var wifiInfo = Wifis.findOne({'_id': Session.get('wifiOnlineId')});
    
    if(type === 'consume' && amount === ''){
      PUB.toast('消费金额不能为空~');
    }else{
      t.$('.scores-submit-form-submit').text('正在处理...');
      Scores.insert({
        type: type,
        amount: amount,
        remark: remark,
        images: [],
        userId: Meteor.userId(),
        userName: Meteor.user().profile.nike,
        wifiId: Session.get('wifiOnlineId'),
        createdAt: new Date()
      }, function(error, _id){
        t.$('.scores-submit-form-submit').text('确定提交');
        if (error)
          PUB.toast('提交失败，请重试~');
        else
          history.go(-2);
      });
    }
    
    return false;
  }
});