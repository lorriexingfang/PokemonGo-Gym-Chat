(function(){if (Meteor.isServer) {
  Meteor.startup(function () {
    // code to run on server at startup
    Accounts.loginServiceConfiguration.remove({
      service: 'weibo'
    });
    Accounts.loginServiceConfiguration.remove({
      service: 'facebook'
    });
    Accounts.loginServiceConfiguration.remove({
      service: 'wechat'
    });
    Accounts.loginServiceConfiguration.remove({
      service: 'qq'
    });
    
    Accounts.loginServiceConfiguration.insert({
      service: 'facebook',
      appId: '614542742044219',
      secret: '347d9abeeed2608b0a111f18deefc12d'
    });
    Accounts.loginServiceConfiguration.insert({
      service: 'weibo',
      clientId: '123490452',
      secret: 'f69795795d96fe8518a4f0bc14d8bf3b'
    });
    Accounts.loginServiceConfiguration.insert({
      service: 'wechat',
      appId: 'wx16433d04aad7f69c',
      secret: 'd731cd79e8417f9bbeaf70e220c551e2'
    });
    ServiceConfiguration.configurations.insert({
      service: "qq",
      clientId: "",
      scope:'',
      secret: ""
    });

  });
}

})();
