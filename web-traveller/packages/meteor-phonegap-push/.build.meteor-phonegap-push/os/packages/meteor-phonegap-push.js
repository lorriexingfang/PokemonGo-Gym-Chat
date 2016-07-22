(function () {

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                     //
// packages/meteor-phonegap-push/android.server.js                                                     //
//                                                                                                     //
/////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                                                                       //
//var gcm = Npm.require('node-gcm');                                                                   // 1
                                                                                                       // 2
// var message = new gcm.Message();                                                                    // 3
// var sender = new gcm.Sender('AIzaSyCDx8v9R0fMsAsjoAffF-P3FCFWXlvwKgL');                             // 4
// var registrationIds = [];                                                                           // 5
                                                                                                       // 6
// message.addData('title','My Game');                                                                 // 7
// message.addData('message','Your turn!!!!');                                                         // 8
// message.addData('msgcnt','1');                                                                      // 9
// message.collapseKey = 'demo';                                                                       // 10
// message.delayWhileIdle = true;                                                                      // 11
// message.timeToLive = 3;                                                                             // 12
                                                                                                       // 13
// // At least one token is required - each app registers a different token                            // 14
// registrationIds.push('APA91bFobAwN7P3Okxy2al8RI12VcJFUS-giXWTOoWXIObtSPOE1h7FuH1VPLBPgshDI_Fp7aIYVET-ssvGUErlWYA0cKPGhoXT1daqyDsEfem9ZtgZNRhQFv7kLCIVSigYlpMluToPiSHSsFSEdtCDfKoOZqNPgfs');
                                                                                                       // 16
// /**                                                                                                 // 17
//  * Parameters: message-literal, registrationIds-array, No. of retries, callback-function            // 18
//  */                                                                                                 // 19
// sender.send(message, registrationIds, 4, function (result) {                                        // 20
//     console.log(result);                                                                            // 21
// });                                                                                                 // 22
// /** Use the following line if you want to send the message without retries                          // 23
// sender.sendNoRetry(message, registrationIds, function (result) {                                    // 24
// console.log(result); });                                                                            // 25
// **/                                                                                                 // 26
/////////////////////////////////////////////////////////////////////////////////////////////////////////

}).call(this);






(function () {

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                     //
// packages/meteor-phonegap-push/ios.server.js                                                         //
//                                                                                                     //
/////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                                                                       //
//var http = require('http');                                                                          // 1
//var apn = Npm.require('apn');                                                                        // 2
//var url = require('url');                                                                            // 3
                                                                                                       // 4
// var myPhone = "d2d8d2a652148a5cea89d827d23eee0d34447722a2e7defe72fe19d733697fb0";                   // 5
// var myiPad = "51798aaef34f439bbb57d6e668c5c5a780049dae840a0a3626453cd4922bc7ac";                    // 6
                                                                                                       // 7
// var myDevice = new apn.Device(myPhone);                                                             // 8
                                                                                                       // 9
// var note = new apn.Notification();                                                                  // 10
// note.badge = 1;                                                                                     // 11
// note.sound = "notification-beep.wav";                                                               // 12
// note.alert = { "body" : "Your turn!", "action-loc-key" : "Play" , "launch-image" : "mysplash.png"}; // 13
// note.payload = {'messageFrom': 'Holly'};                                                            // 14
                                                                                                       // 15
// note.device = myDevice;                                                                             // 16
                                                                                                       // 17
// var callback = function(errorNum, notification){                                                    // 18
//     console.log('Error is: %s', errorNum);                                                          // 19
//     console.log("Note " + notification);                                                            // 20
// }                                                                                                   // 21
// var options = {                                                                                     // 22
//     gateway: 'gateway.sandbox.push.apple.com', // this URL is different for Apple's Production Servers and changes when you go to production
//     errorCallback: callback,                                                                        // 24
//     cert: 'PushNotificationSampleCert.pem',                                                         // 25
//     key:  'PushNotificationSampleKey.pem',                                                          // 26
//     passphrase: 'myPassword',                                                                       // 27
//     port: 2195,                                                                                     // 28
//     enhanced: true,                                                                                 // 29
//     cacheLength: 100                                                                                // 30
// }                                                                                                   // 31
// var apnsConnection = new apn.Connection(options);                                                   // 32
// apnsConnection.sendNotification(note);                                                              // 33
/////////////////////////////////////////////////////////////////////////////////////////////////////////

}).call(this);






(function () {

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                     //
// packages/meteor-phonegap-push/push.server.js                                                        //
//                                                                                                     //
/////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                                                                       //
/*                                                                                                     // 1
  A general purpose user CordovaPush                                                                   // 2
  ios, android, mail, twitter?, facebook?, sms?, snailMail? :)                                         // 3
                                                                                                       // 4
  Phonegap generic :                                                                                   // 5
  https://github.com/phonegap-build/PushPlugin                                                         // 6
 */                                                                                                    // 7
                                                                                                       // 8
// getText / getBinary                                                                                 // 9
                                                                                                       // 10
                                                                                                       // 11
CordovaPush = function(androidServerKey, options) {                                                    // 12
    var self = this;                                                                                   // 13
                                                                                                       // 14
    // This function is called when a token is replaced on a device - normally                         // 15
    // this should not happen, but if it does we should take action on it                              // 16
    self.replaceToken = (typeof options.onReplace === 'function')?                                     // 17
                    options.onReplace:function(oldToken, newToken) {                                   // 18
                        console.log('Replace token: ' + oldToken + ' -- ' + newToken);                 // 19
                    };                                                                                 // 20
                                                                                                       // 21
    self.removeToken = (typeof options.onRemove === 'function')?                                       // 22
                    options.onRemove:function(token) {                                                 // 23
                        console.log('Remove token: ' + token);                                         // 24
                    };                                                                                 // 25
                                                                                                       // 26
    if (!options['certData'] || !options['certData'].length)                                           // 27
        console.log('Push server could not find certData');                                            // 28
                                                                                                       // 29
    if (!options['keyData'] || !options['keyData'].length)                                             // 30
        console.log('Push server could not find keyData');                                             // 31
                                                                                                       // 32
                                                                                                       // 33
    // https://npmjs.org/package/apn                                                                   // 34
                                                                                                       // 35
    // After requesting the certificate from Apple, export your private key as a .p12 file and download the .cer file from the iOS Provisioning Portal.
                                                                                                       // 37
    // gateway.push.apple.com, port 2195                                                               // 38
    // gateway.sandbox.push.apple.com, port 2195                                                       // 39
                                                                                                       // 40
    // Now, in the directory containing cert.cer and key.p12 execute the following commands to generate your .pem files:
    // $ openssl x509 -in cert.cer -inform DER -outform PEM -out cert.pem                              // 42
    // $ openssl pkcs12 -in key.p12 -out key.pem -nodes                                                // 43
                                                                                                       // 44
    var apn = Npm.require('apn');                                                                      // 45
                                                                                                       // 46
    var apnConnection = new apn.Connection( options );                                                 // 47
    // (cert.pem and key.pem)                                                                          // 48
    self.sendIOS = function(from, userToken, title, text, count, priority) {                           // 49
                                                                                                       // 50
        priority = (priority || priority === 0)? priority : 10;                                        // 51
                                                                                                       // 52
        var myDevice = new apn.Device(userToken);                                                      // 53
                                                                                                       // 54
        var note = new apn.Notification();                                                             // 55
                                                                                                       // 56
        note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.                // 57
        note.badge = count;                                                                            // 58
        //note.sound = ""; // XXX: Does this work?                                                     // 59
        note.alert = text;                                                                             // 60
        note.payload = {'messageFrom': from };                                                         // 61
        note.priority = priority;                                                                      // 62
                                                                                                       // 63
        //console.log('I:Send message to: ' + userToken + ' count=' + count);                          // 64
                                                                                                       // 65
        apnConnection.pushNotification(note, myDevice);                                                // 66
                                                                                                       // 67
    };                                                                                                 // 68
                                                                                                       // 69
    self.sendAndroid = function(from, userTokens, title, text, count) {                                // 70
        var gcm = Npm.require('node-gcm');                                                             // 71
        var Fiber = Npm.require('fibers');                                                             // 72
                                                                                                       // 73
        //var message = new gcm.Message();                                                             // 74
        var message = new gcm.Message({                                                                // 75
            collapseKey: from,                                                                         // 76
        //    delayWhileIdle: true,                                                                    // 77
        //    timeToLive: 4,                                                                           // 78
        //    restricted_package_name: 'dk.gi2.driftsstatus'                                           // 79
            data: {                                                                                    // 80
                title: title,                                                                          // 81
                message: text,                                                                         // 82
                msgcnt: count                                                                          // 83
            }                                                                                          // 84
        });                                                                                            // 85
        var sender = new gcm.Sender(androidServerKey);                                                 // 86
                                                                                                       // 87
        _.each(userTokens, function(value, key) {                                                      // 88
            //console.log('A:Send message to: ' + value + ' count=' + count);                          // 89
        });                                                                                            // 90
                                                                                                       // 91
        /*message.addData('title', title);                                                             // 92
        message.addData('message', text);                                                              // 93
        message.addData('msgcnt', '1');                                                                // 94
        message.collapseKey = 'sitDrift';                                                              // 95
        message.delayWhileIdle = true;                                                                 // 96
        message.timeToLive = 3;*/                                                                      // 97
                                                                                                       // 98
        // /**                                                                                         // 99
        //  * Parameters: message-literal, userTokens-array, No. of retries, callback-function         // 100
        //  */                                                                                         // 101
                                                                                                       // 102
        var userToken = (userTokens.length === 1)?userTokens[0]:null;                                  // 103
                                                                                                       // 104
        sender.send(message, userTokens, 5, function (err, result) {                                   // 105
            if (err) {                                                                                 // 106
                //console.log('ANDROID ERROR: result of sender: ' + result);                           // 107
            } else {                                                                                   // 108
                //console.log('ANDROID: Result of sender: ' + JSON.stringify(result));                 // 109
                if (result.canonical_ids === 1 && userToken) {                                         // 110
                                                                                                       // 111
                    // This is an old device, token is replaced                                        // 112
                    Fiber(function(self) {                                                             // 113
                        // Run in fiber                                                                // 114
                        try {                                                                          // 115
                            self.callback(self.oldToken, self.newToken);                               // 116
                        } catch(err) {                                                                 // 117
                                                                                                       // 118
                        }                                                                              // 119
                                                                                                       // 120
                    }).run({                                                                           // 121
                        oldToken: { androidToken: userToken },                                         // 122
                        newToken: { androidToken: result.results[0].registration_id },                 // 123
                        callback: self.replaceToken                                                    // 124
                    });                                                                                // 125
                    //self.replaceToken({ androidToken: userToken }, { androidToken: result.results[0].registration_id });
                                                                                                       // 127
                }                                                                                      // 128
                // We cant send to that token - might not be registred                                 // 129
                // ask the user to remove the token from the list                                      // 130
                if (result.failure !== 0 && userToken) {                                               // 131
                                                                                                       // 132
                    // This is an old device, token is replaced                                        // 133
                    Fiber(function(self) {                                                             // 134
                        // Run in fiber                                                                // 135
                        try {                                                                          // 136
                            self.callback(self.token);                                                 // 137
                        } catch(err) {                                                                 // 138
                                                                                                       // 139
                        }                                                                              // 140
                                                                                                       // 141
                    }).run({                                                                           // 142
                        token: { androidToken: userToken },                                            // 143
                        callback: self.removeToken                                                     // 144
                    });                                                                                // 145
                    //self.replaceToken({ androidToken: userToken }, { androidToken: result.results[0].registration_id });
                                                                                                       // 147
                }                                                                                      // 148
                                                                                                       // 149
            }                                                                                          // 150
        });                                                                                            // 151
        // /** Use the following line if you want to send the message without retries                  // 152
        // sender.sendNoRetry(message, userTokens, function (result) {                                 // 153
        //     console.log('ANDROID: ' + JSON.stringify(result));                                      // 154
        // });                                                                                         // 155
        // **/                                                                                         // 156
    }; // EO sendAndroid                                                                               // 157
                                                                                                       // 158
    self.initFeedback = function() {                                                                   // 159
        var apn = Npm.require('apn');                                                                  // 160
                                                                                                       // 161
        var feedbackOptions = {                                                                        // 162
            "batchFeedback": true,                                                                     // 163
            "interval": 1000,                                                                          // 164
            'address': 'feedback.push.apple.com'                                                       // 165
        };                                                                                             // 166
                                                                                                       // 167
        var feedback = new apn.Feedback(feedbackOptions);                                              // 168
        feedback.on("feedback", function(devices) {                                                    // 169
            devices.forEach(function(item) {                                                           // 170
                // Do something with item.device and item.time;                                        // 171
                console.log('A:PUSH FEEDBACK ' + item.device + ' - ' + item.time);                     // 172
            });                                                                                        // 173
        });                                                                                            // 174
    };                                                                                                 // 175
                                                                                                       // 176
                                                                                                       // 177
    return self;                                                                                       // 178
};                                                                                                     // 179
                                                                                                       // 180
/////////////////////////////////////////////////////////////////////////////////////////////////////////

}).call(this);
