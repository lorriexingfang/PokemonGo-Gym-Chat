var PushNotification = function() {
};


// Call this to register for push notifications. Content of [options] depends on whether we are working with APNS (iOS) or GCM (Android)
PushNotification.prototype.register = function(successCallback, errorCallback, options) {
    if (errorCallback == null) { errorCallback = function() {}}

    if (typeof errorCallback != "function")  {
        console.log("PushNotification.register failure: failure parameter not a function");
        return
    }

    if (typeof successCallback != "function") {
        console.log("PushNotification.register failure: success callback parameter must be a function");
        return
    }

    cordova.exec(successCallback, errorCallback, "PushPlugin", "register", [options]);
};

PushNotification.prototype.UserNotificationTypes = {
    Badge : "badge",
    Alert : "alert",
    Sound : "sound"
};

PushNotification.prototype.UserNotificationActivationMode = {
    Foreground : "foreground",
    Background : "background"
};

PushNotification.prototype.ActionBehavior = {
    TextInput : "textInput"
};

PushNotification.prototype.registerUserNotificationSettings = function(successCallback, errorCallback, options) {
    if (errorCallback == null) { errorCallback = function() {}}

    if (typeof errorCallback != "function")  {
        console.log("PushNotification.registerUserNotificationSettings failure: failure parameter not a function");
        return
    }

    if (typeof successCallback != "function") {
        console.log("PushNotification.registerUserNotificationSettings failure: success callback parameter must be a function");
        return
    }

    cordova.exec(successCallback, errorCallback, "PushPlugin", "registerUserNotificationSettings", [options]);
};


// Call this to unregister for push notifications
PushNotification.prototype.unregister = function(successCallback, errorCallback, options) {
    if (errorCallback == null) { errorCallback = function() {}}

    if (typeof errorCallback != "function")  {
        console.log("PushNotification.unregister failure: failure parameter not a function");
        return
    }

    if (typeof successCallback != "function") {
        console.log("PushNotification.unregister failure: success callback parameter must be a function");
        return
    }

     cordova.exec(successCallback, errorCallback, "PushPlugin", "unregister", [options]);
};

// Check to see if we've already registered
PushNotification.prototype.areNotificationsEnabled = function(successCallback, errorCallback, options) {
    if (errorCallback == null) { errorCallback = function() {}}

    if (typeof errorCallback != "function")  {
        console.log("PushNotification.areNotificationsEnabled failure: failure parameter not a function");
        return
    }

    if (typeof successCallback != "function") {
        console.log("PushNotification.areNotificationsEnabled failure: success callback parameter must be a function");
        return
    }

    cordova.exec(successCallback, errorCallback, "PushPlugin", "areNotificationsEnabled", [options]);
};

// Call this if you want to show toast notification on WP8
PushNotification.prototype.showToastNotification = function (successCallback, errorCallback, options) {
    if (errorCallback == null) { errorCallback = function () { } }

    if (typeof errorCallback != "function") {
        console.log("PushNotification.register failure: failure parameter not a function");
        return
    }

    cordova.exec(successCallback, errorCallback, "PushPlugin", "showToastNotification", [options]);
};

// Call this to set the application icon badge
PushNotification.prototype.setApplicationIconBadgeNumber = function(successCallback, errorCallback, badge) {
    if (errorCallback == null) { errorCallback = function() {}}

    if (typeof errorCallback != "function")  {
        console.log("PushNotification.setApplicationIconBadgeNumber failure: failure parameter not a function");
        return
    }

    if (typeof successCallback != "function") {
        console.log("PushNotification.setApplicationIconBadgeNumber failure: success callback parameter must be a function");
        return
    }

    cordova.exec(successCallback, errorCallback, "PushPlugin", "setApplicationIconBadgeNumber", [{badge: badge}]);
};

// Call this to notifiy iOS native code that the push notification was processed
PushNotification.prototype.notificationProcessed = function() {
    cordova.exec({}, {}, "PushPlugin", "notificationProcessed");
};

//-------------------------------------------------------------------

if(!window.plugins) {
    window.plugins = {};
}
if (!window.plugins.pushNotification) {
    window.plugins.pushNotification = new PushNotification();
}

if (typeof module != 'undefined' && module.exports) {
  module.exports = PushNotification;
}