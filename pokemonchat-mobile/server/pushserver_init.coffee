root = exports ? this
if Meteor.isServer
  Meteor.startup ()->
    #Files are placed in the `/private` folder:
    apnsDevCert = Assets.getText 'PushStorebbsDevCert.pem'
    apnsDevKey = Assets.getText 'PushStorebbsDevKey.pem'
    optionsDevelopment =
        passphrase: '1234'
        certData: apnsDevCert
        keyData: apnsDevKey
        gateway: 'gateway.sandbox.push.apple.com'
    
    apnsProductionCert = Assets.getText 'PushStorebbsProCert.pem'
    apnsProductionKey = Assets.getText 'PushStorebbsProKey.pem'
    optionsProduction =
        passphrase: '1234'
        certData: apnsProductionCert
        keyData: apnsProductionKey
        gateway: 'gateway.push.apple.com'

    pushServer2 = new CordovaPush 'Android server key', optionsProduction

    pushServer2.initFeedback()
    root.pushServer2 = pushServer2