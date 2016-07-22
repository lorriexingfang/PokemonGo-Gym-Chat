if (Meteor.isServer) {
  Accounts.registerLoginHandler('facebook', function(options) {
    if (!options.facebook || !options.facebook.id) {
      return void 0;
    }
    
    return Accounts.updateOrCreateUserFromExternalService('facebook', options.facebook, {
      username: options.facebook.name,
      createdAt: new Date(),
      profile: {
        fullname: options.facebook["name"],
        icon: options.facebook.picture.data.url,
        sex: void 0,
        location: void 0
      }
    });
  });
}