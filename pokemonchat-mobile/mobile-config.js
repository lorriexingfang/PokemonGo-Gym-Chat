App.info({
  id: 'org.storebbs.together',
  version: '1.0.14',
  name: 'PokegymGo',
  description: 'Small business',
  author: 'Pokegym Go Design Team',
  email: '',
  website: ''
});

App.configurePlugin('cordova-plugin-x-socialsharing', {
  APP_ID: 'wx2600c1664d3483bd'
});

App.configurePlugin('cordova-plugin-facebook4', {
    APP_NAME: 'PokegymGo',
    APP_ID: '614542742043219'
});

App.configurePlugin('com.share.wechatShare', {
    APP_ID: 'wx2600c1664d3084bd'
});

App.configurePlugin('Keyboard', {
    "ios-package": 'CDVKeyboard'
});

App.accessRule('http://*');
App.accessRule('https://*');
App.setPreference('StatusBarOverlaysWebView', 'false');
App.setPreference('orientation', 'portrait');
App.setPreference('StatusBarBackgroundColor', '#374A53');
//App.setPreference('BackupWebStorage', 'none');
App.setPreference('KeyboardDisplayRequiresUserAction', false);
App.setPreference('AndroidPersistentFileLocation','Internal');
App.setPreference('iosPersistentFileLocation','Library');
App.accessRule('*');
App.accessRule('http://*');
App.accessRule('https://*');

App.icons({
  'iphone': 'resource/icon_57.png',
  'iphone_2x': 'resource/icon_120.png',
  'iphone_3x': 'resource/icon_180.png',
  'ipad': 'resource/icon_76.png',
  'ipad_2x': 'resource/icon_152.png',
  'android_ldpi': 'resource/icon_36.png',
  'android_mdpi': 'resource/icon_48.png',
  'android_hdpi': 'resource/icon_96.png',
  'android_xhdpi': 'resource/icon.png'
});

App.launchScreens({
  'iphone': 'resource/launchScreen_640_960.png',
  'iphone_2x': 'resource/launchScreen_640_960.png',
  'iphone5': 'resource/launchScreen_640_1136.png',
  'iphone6': 'resource/launchScreen_750_1334.png',
  'iphone6p_portrait': 'resource/launchScreen_1242_2208.png',
  'android_ldpi_portrait': 'resource/launchScreen_480_800.png',
  'android_mdpi_portrait': 'resource/launchScreen_480_800.png',
  'android_hdpi_portrait': 'resource/launchScreen_480_800.png',
  'android_xhdpi_portrait': 'resource/launchScreen_480_800.png'
});
