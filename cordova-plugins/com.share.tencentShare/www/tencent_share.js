var TencentShare = function() {};

TencentShare.prototype.qqShare = function(options, success, fail) {
  cordova.exec(function(result) {
    success(result);
  }, function() {
    fail();
  }, "TencentShare", "qqShare", [options]);
};

TencentShare.prototype.qzoneShare = function(options, success, fail) {
  cordova.exec(function(result) {
    success(result);
  }, function() {
    fail();
  }, "TencentShare", "qzoneShare", [options]);
};

var tencentShare = new TencentShare();
module.exports = tencentShare;
