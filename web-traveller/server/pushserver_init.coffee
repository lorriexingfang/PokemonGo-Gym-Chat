root = exports ? this
if Meteor.isServer
  Meteor.startup ()->
    #Files are placed in the `/private` folder:
    apnsDevCert = Assets.getText 'apns_development.pem'
    apnsDevKey = Assets.getText 'PushNotificationTravelers_Together.pem'
    optionsDevelopment =
        passphrase: '123456'
        certData: apnsDevCert
        keyData: apnsDevKey
        gateway: 'gateway.sandbox.push.apple.com'
    
    apnsProductionCert = Assets.getText 'PushTravelersCert.pem'
    apnsProductionKey = Assets.getText 'PushTravelersKey.pem'
    optionsProduction =
        passphrase: '1234'
        certData: apnsProductionCert
        keyData: apnsProductionKey
        gateway: 'gateway.push.apple.com'

    pushServer = new CordovaPush 'Android server key', optionsProduction

    pushServer.initFeedback()
    root.pushServer = pushServer