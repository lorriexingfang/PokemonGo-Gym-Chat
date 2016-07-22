/**
  * @bishen
  * 2014.11.4
  */
if (Meteor.isClient){
  Template.my_dashboard.helpers({
      goRegister:function() {
          return Session.equals('goRegister',true);
      },
      editProfile:function() {
          return Session.equals('editProfile',true);
      },
      userSex:function(){
        return Meteor.user().profile.sex=='女';
      }
  });
  Template.my_dashboard.rendered = function(){
      Session.set('goRegister',false);
      Session.set('editProfile',false);
  }
  Template.my_register.rendered = function(){
    Session.set("upload_images", new Array());
  }
  Template.my_dashboard.events({
      // 登录
      'submit #login-form' : function(e, t){
        e.preventDefault();
        var name = t.find('#login-name').value
          , password = t.find('#login-password').value;
          Meteor.loginWithPassword(name, password, function(err){

        });
           return false;
       },
      // 编辑
      'click #edit-button':function(e, t){
          Session.set('editProfile',true);
      },
      'click #back-my':function(e, t){
          Session.set('editProfile',false);
      },
      'submit #edit-form' : function(e, t) {
            e.preventDefault();
            var city = t.find('#account-city').value;
            var sex = t.find('#account-woman').checked?'女':'男';
            var picture = Session.get("upload_images").length>0?Session.get("upload_images")[0].url:'';
            Meteor.users.update(Meteor.userId(),{$set: {profile: {city:city,sex:sex,picture:picture}}});
            Session.set('editProfile',false);
            return false;
      },
      // 退出
      'click #logout-button':function(e, t){
          Meteor.logout(function(msg){
              console.log(msg);
          });
      },
      // 注册
      'click #back-button':function(e, t){
          Session.set('goRegister',false);
      },
      'click #register-button':function(e, t){
          Session.set('goRegister',true);
      },
      'submit #register-form' : function(e, t) {
        e.preventDefault();
        var name = t.find('#account-name').value;
        var password = t.find('#account-password').value;
        var profile = {
            city:t.find('#account-city').value,
            sex:t.find('#account-woman').checked?'女':'男',
            picture:Session.get("upload_images").length>0?Session.get("upload_images")[0].url:''
        }
        Accounts.createUser({username: name, password : password,profile:profile}, function(err){
            if (err) {
              //alert('注册失败：'+err);
              window.plugins.toast.showLongBottom('注册失败：'+err);
            } else {
              //alert('注册成功！');
              window.plugins.toast.showLongBottom('注册成功！');
              updatePushNotificationToken(Session.get('registrationType'),Session.get('registrationID'));
            }
          });

        return false;
      },
      'click #set-profile-photo': function (e,t){
        uploadFile(function(result){
          if(result){
            console.log('got result ' + result);
            Meteor.users.update({_id:Meteor.user()._id}, {$set:{profile:{picture:result}}});
          }
        });
      }
  });
}