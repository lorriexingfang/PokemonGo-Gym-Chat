var WeiboShare = function() {};

WeiboShare.prototype.share = function(options, success, fail) {
  cordova.exec(function(result) {
    success(result);
  }, function() {
    fail();
  }, "WeiboShare", "share", [options]);
};

var weiboShare = new WeiboShare();
module.exports = weiboShare;
