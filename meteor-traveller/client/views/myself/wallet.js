$(window).scroll(function(){
  var scrollTop = $(this).scrollTop();
  var scrollHeight = $(document).height();
  var windowHeight = $(this).height(); 
  
  if(Session.equals('view', 'my_wallet') && scrollTop > 0 && scrollTop >= scrollHeight-windowHeight){
    Session.set('my_wallet_limit', Session.get('my_wallet_limit')+20);
    Meteor.subscribe('my_wallet', Session.get('my_wallet_limit'));
  }
});

Template.my_wallet.onRendered(function(){
  Session.set('my_wallet_limit', 20);
  Session.set('my_wallet_view', 'my_wallet_effective');
  Meteor.subscribe('my_wallet', Session.get('my_wallet_limit'))
});
Template.my_wallet.helpers({
  template: function(){
    return Session.get('my_wallet_view'); 
  },
  isTemplate: function(val){
    return Session.equals('my_wallet_view', val); 
  }
});
Template.my_wallet.events({
  'click .leftButton': function(){
    window.page.back();
  },
  'click .tags li': function(e){
    Session.set('my_wallet_view', e.currentTarget.id);
  }
});

Template.my_wallet_effective.helpers({
  hasMoreData: function(){
    var count = Template.my_wallet_effective.__helpers.get('wallet')().count();
    if(count <= 0 || count < 20)
      return false;
    return !(Session.get('my_wallet_limit') > count);
  },
  wallet: function(){
    return Chats.find({toUserId: Meteor.userId(),msgType:'wifiCard'}, {sort: {createdAt: -1}, limit:Session.get('my_wallet_limit')});
  }
});

Template.my_wallet_effective.events({
   'click .photo img': function(e){
        e.stopPropagation();
        var images = new Array();
        var wallets = Template.my_wallet_effective.__helpers.get('wallet')()
        wallets.forEach(function(item) {
                if (item.photoPath != undefined && item.photoPath != '' && item.photoPath != null) {
                    return images.push(item.photoPath);
                }
        });
        Session.set("images_view_images", images);
        Session.set("images_view_images_selected", e.currentTarget.src);
        Session.set("return_view", Session.get("view"));
        Session.set("document.body.scrollTop", document.body.scrollTop);
        PUB.page("images_view");
    }
  });