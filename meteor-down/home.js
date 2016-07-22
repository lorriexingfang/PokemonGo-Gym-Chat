
meteorDown.init(function (Meteor){
  Meteor.subscribe('wifiLists',null,10,function(){
    console.log('Subscription is ready');
    console.log(Meteor.collections.wifis);
    Meteor.subscribe('wifiBSSID','10:9f:a9:70:01:2f',function(){
      Meteor.kill();
    });
  });
});
meteorDown.run({
  concurrency: 10,
  url: 'http://localhost:3000',
  key: undefined,
  auth: undefined
});
