# cordova-plugin-tencent-share


## Using the plugin

Example -share to qq friend
```javascript
TencentShare.qqShare({
    "appid": "xxxxxxx",
    "title": "title",
    "summary": "summary",
    "image_url": "http://img3.cache.netease.com/photo/0005/2013-03-07/8PBKS8G400BV0005.jpg",
    "target_url": "http://weibo.com/u/5398990359"
}, function() {
      console.log("ok");
}, function() {
    console.log("error");
});
```
Example -share to qzone 
```javascript
TencentShare.qzoneShare({
    "appid": "xxxxxxx",
    "title": "title",
    "summary": "summary",
    "image_url": "http://img3.cache.netease.com/photo/0005/2013-03-07/8PBKS8G400BV0005.jpg",
    "target_url": "http://weibo.com/u/5398990359"
}, function() {
      console.log("ok");
}, function() {
    console.log("error");
});
```
