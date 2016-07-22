Meteor.startup(function(){
  if(!Meteor.isCordova)
    return;
  
  var wifiInfo = {status: 'offline'};
  var timeout = null;
  var onwifi = function(error, status, info){
    console.log('on wifi');
    if(error){
      console.log(error);
      return;
    }
    
    if(status === 'online'){
      console.log('wifi online.');
      console.log('wifi info: ' + JSON.stringify(info));
      
//      if(!wifiInfo.isBlackboard && !wifiInfo.isMerchant){
//        amplify.store('wifi_guide_', true);
//        if(!amplify.store('wifi_guide_' + wifiInfo.info.BSSID)){
//          amplify.store('wifi_guide_' + wifiInfo.info.BSSID, true);
//          Blaze.renderWithData(Template.wifiGuide, {wifi_name: wifiInfo.info.SSID}, document.getElementsByTagName('body')[0]);
//        }
//      }
    }else{
      console.log('wifi offline.');
    }
  };
  var updateWifiInfo = function(){
    console.log('updateWifiInfo...');
    if(navigator.connection.type != Connection.WIFI){
      if(timeout != null){
        Meteor.clearTimeout(timeout);
        timeout = null;
      }
      wifiInfo.status = 'offline';
      onwifi(null, 'offline');
      return;
    }
    if(timeout != null){
      Meteor.clearTimeout(timeout);
      timeout = null;
    }
    
    timeout = Meteor.setTimeout(function(){
      navigator.wifi.getConnectedWifiInfo(function(result) {
        if(result){
          if(result.SSID)
            result.SSID = result.SSID.replace("\"", "").replace("\'", "");
          if(result.BSSID)
            result.BSSID = result.BSSID.toLowerCase();
          if(result.BSSID){
            var bssid = '';
            for(var item in result.BSSID.split(':')){
              if(bssid != '')
                bssid += ':';
              if(item.length <= 1)
                bssid += '0' + item;
              else
                bssid += item;
            }
            result.BSSID = bssid;
          }
          if(wifiInfo.info){
            if(wifiInfo.info.BSSID != result.BSSID){
              Meteor.subscribe('getWifiInfoBybssid', result.BSSID, {onReady: function(){
                if(Wifis.find({'BSSID': result.BSSID}).count() > 0)
                  wifiInfo.isBlackboard = true;
                else
                  wifiInfo.isBlackboard = false;
                if(Meteor.users.find({'business.wifi.BSSID': bssid, 'profile.isBusiness': 1}).count() > 0)
                  wifiInfo.isMerchant = true;
                else
                  wifiInfo.isMerchant = false;
                
                wifiInfo.status = 'online';
                wifiInfo.info = result;
                onwifi(null, 'online', result);
              }, onError: function(error){
                onwifi(error);
              }, onStop: function(){
                onwifi(new Error('subscribe is stop'));
              }});
            }else{
              wifiInfo.status = 'online';
              onwifi(null, 'online', result);
            }
          }
        }else{
          onwifi(null, 'offline'); 
        }
        timeout = null;
      });
    }, 0);
  };
  
//  updateWifiInfo();
//  document.addEventListener("deviceready", updateWifiInfo, false);
//  document.addEventListener("online", updateWifiInfo, false);
//  document.addEventListener("offline", updateWifiInfo, false);
//  document.addEventListener("pause", updateWifiInfo, false);
//  document.addEventListener("resume", updateWifiInfo, false);
});