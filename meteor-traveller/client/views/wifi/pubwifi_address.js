Template.wifiPubwifiAddress.events({
  'click #btn_back': function() {
    window.page.back();
  },
  'click .btn-submit': function(e) {
    window.page.back();
    var address = $('#wifi_address').val();
    Wifis.update({_id: Session.get('wifiOnlineId')}, {$set: {'location.address': address}}, function(err, number) {
          if(err || number <= 0) {
                PUB.toast('修改地址失败，请重试！');
          }
    });    
  }
});

Template.wifiPubwifiAddress.helpers({
  'oldAddress': function () {
    return Session.get('myWifiPubwifiAddress');
  }
});