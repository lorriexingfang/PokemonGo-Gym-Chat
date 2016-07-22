getPosition = function(callback){
  callback = callback || function(){};
  
  var getAddress = function(position){
    var geoc = new BMap.Geocoder();
    var point = new BMap.Point(position.longitude, position.latitude);
    geoc.getLocation(point, function(rs){
      if(rs && rs.addressComponents ){
        var addComp = rs.addressComponents;
        if(addComp.city && addComp.city !== ''){
          //alert(addComp.province + ", " + addComp.city + ", " + addComp.district + ", " + addComp.street + ", " + addComp.streetNumber);
          Session.set("location_city",addComp.city);
          if(Session.get("city") === undefined)
              Session.set("city", addComp.city);
          console.log("location city is " + addComp.city);
          callback(null, {position: position, address: addComp});
          return;
        }
      }
      
      callback(null, {position: position});
    });
  };
  
  if(Meteor.isCordova){
    window.navigator.geolocation.getCurrentPosition(function(position){
      console.log('\nLatitude: '          + position.coords.latitude          + '\n' +
                  'Longitude: '         + position.coords.longitude         + '\n' +
                  'Accuracy: '          + position.coords.accuracy          + '\n' +
                  'Timestamp: '         + position.timestamp                + '\n');
      Session.set('location',{latitude: position.coords.latitude, longitude:position.coords.longitude,type:'geo',accuracy:position.coords.accuracy });
      getAddress({latitude: position.coords.latitude, longitude:position.coords.longitude,type:'geo',accuracy:position.coords.accuracy });
    }, function(error){
      console.log('code: ' + error.code + '\n' + 'message: ' + error.message + '\n');
      Meteor.call('getGeoFromConnection',function(err,response){
        if(err){
          callback(err);
          return;
        }
        
        console.log('Geo Location is ' + JSON.stringify(response));
        var location = Session.get('location');
        if(location && location.type !== 'geo'){
          Session.set('location',{latitude:response.ll[0],longitude:response.ll[1],type:'ip'});
        }
        getAddress({latitude:response.ll[0],longitude:response.ll[1],type:'ip'});
      });
    }, {maximumAge: 600000, timeout: 60000, enableHighAccuracy: false});
  }else{
    Meteor.call('getGeoFromConnection',function(err,response){
      if(err){
        callback(err);
        return;
      }
      
      console.log('Geo Location is ' + JSON.stringify(response));
      var location = Session.get('location');
      if(location && location.type !== 'geo'){
        Session.set('location',{latitude:response.ll[0],longitude:response.ll[1],type:'ip'});
      }
      getAddress({latitude:response.ll[0],longitude:response.ll[1],type:'ip'});
    });
  }
};