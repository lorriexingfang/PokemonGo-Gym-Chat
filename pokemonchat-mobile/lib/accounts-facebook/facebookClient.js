if (Meteor.isClient) {
    var getFacebookInfo = function(callback) {
        //return true;
        var fbLoginSuccess = function (userData) {
            facebookConnectPlugin.api('/me?fields=id,name,picture', [],
                function (result) {
                    if(result){
                        callback(result);
                    } else {
                        callback(null);
                    } 
                },
                function (error) { 
                    callback(null);
                } 
            );
        }

        facebookConnectPlugin.login(["public_profile"], fbLoginSuccess,
            function loginError (error) {
                console.error(error)
            }
        );
    };



    Meteor.loginWithFacebook = function (callback) {
        getFacebookInfo(function(result){
            if (result) {
                  var options;
                  options = {
                      device: {
                          time: new Date()
                      },
                      facebook: result
                   };

            console.log("-----------Facebook login data is: " + JSON.stringify(options));

                Accounts.callLoginMethod({
                    methodArguments: [options],
                    userCallback: function (err, res) {
                        if (err) {
                            return callback(err);
                        } else {
                            return callback(null, res);
                        }
                    }
                });
            } else {
                callback("The Facebook logon failure.");
            }
        }, function(){
            callback("The Facebook logon failure.");
        });
    };
}