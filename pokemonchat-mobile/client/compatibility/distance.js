function distance(lon1, lat1, lon2, lat2) {
  if (lon1 == undefined || lat1 == undefined || lon2 == undefined || lat2 == undefined) {
    return '';
  }
  var R = 6371; // Radius of the earth in km
  var dLat = (lat2-lat1).toRad();  // Javascript functions in radians
  var dLon = (lon2-lon1).toRad(); 
  var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
          Math.cos(lat1.toRad()) * Math.cos(lat2.toRad()) * 
          Math.sin(dLon/2) * Math.sin(dLon/2); 
  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
  var d = R * c; // Distance in km
  var re = /([0-9]+\.[0-9]{1})[0-9]*/; //保留一位小数
  if(d < 1)
    return Math.round(d*1000)+"m"
  else if(d < 1000)
    return Math.round(d)+"km"
  else
    return ">1000km"
}

/** Converts numeric degrees to radians */
if (typeof(Number.prototype.toRad) === "undefined") {
  Number.prototype.toRad = function() {
    return this * Math.PI / 180;
  }
}