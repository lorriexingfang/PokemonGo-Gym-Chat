var bcsStringPattern = /http:\/\/bcs.duapp.com\/travelers-km\//g;
var bcsString = 'http://bcs.duapp.com/travelers-km/';
var bosString = 'http://bos.youzhadahuo.com/';

var bcsStringPattern2 = /http:\/\/bcs.duapp.com\/travelers-km-public\//g;
var bcsString2 = 'http://bcs.duapp.com/travelers-km-public/';
var bosString2 = 'http://bospublic.youzhadahuo.com/';

if (Meteor.isServer)
{
    Meteor.startup(function(){
        var replaceLocation = function(){
          var usersRecords = Meteor.users.find({}).fetch();
          console.log("Meteor.users count="+Meteor.users.find({}).count());
          count1 = 0;
          for (var i in usersRecords) {
              var item = usersRecords[i];
              var businessLocation
              if (item.profile && item.profile.isBusiness && item.profile.location ) {
                  businessLocation = item.profile.location;
                  Meteor.users.update({_id: item._id}, {$set: {'profile.businessLocation':businessLocation}});
              }else if (item.profile && item.profile.isBusiness && item.profile.lastLocation) {
                  businessLocation = item.profile.lastLocation;
                  Meteor.users.update({_id: item._id}, {$set: {'profile.businessLocation':businessLocation}});
              }
          }
        }

        var replaceToBOS = function() {
            console.log("bcsStringPattern="+bcsStringPattern+", bcsString="+bcsString+", bosString="+bosString);
            //chatUsers
            var count1=0, count2=0;
            var chatUsersRecords = ChatUsers.find({}).fetch();
            //chatUsersRecords.forEach(function(item) {
            //for (var i=0, len=chatUsersRecords.length; i < len; i++) {
            //console.log("ChatUsers count="+ChatUsers.find({}).count());
            for (var i in chatUsersRecords) {
                var item = chatUsersRecords[i];
                //console.log("item.userPicture = "+ item.userPicture +", item="+JSON.stringify(item));
                if (item.userPicture && item.userPicture.indexOf(bcsString) >= 0) {
                    count1++;
                    item.userPicture = item.userPicture.replace(bcsStringPattern, bosString);
                    //console.log("item.userPicture="+item.userPicture);
                    ChatUsers.update({_id: item._id}, {$set: {userPicture:item.userPicture}});
                }
                if (item.toUserPicture && item.toUserPicture.indexOf(bcsString) >= 0) {
                    count2++;
                    item.toUserPicture = item.toUserPicture.replace(bcsStringPattern, bosString);
                    ChatUsers.update({_id: item._id}, {$set: {toUserPicture:item.toUserPicture}});
                }
            }
            console.log("ChatUsers: userPicture:"+count1+", toUserPicture="+count2);

            //Chats
            var chatsRecords = Chats.find({}).fetch();
            console.log("Chats count="+Chats.find({}).count());
            count1 = 0;
            count2 = 0;
            for (var i in chatsRecords) {
                var item = chatsRecords[i];
                if (item.userPicture && item.userPicture.indexOf(bcsString) >= 0) {
                    count1++;
                    item.userPicture = item.userPicture.replace(bcsStringPattern, bosString);
                    Chats.update({_id: item._id}, {$set: {userPicture:item.userPicture}});
                }
                if (item.toUserPicture && item.toUserPicture.indexOf(bcsString) >= 0) {
                    count2++;
                    item.toUserPicture = item.toUserPicture.replace(bcsStringPattern, bosString);
                    Chats.update({_id: item._id}, {$set: {toUserPicture:item.toUserPicture}});
                }
                if (item.photoPath && item.photoPath.indexOf(bcsString) >= 0) {
                    count1++;
                    item.photoPath = item.photoPath.replace(bcsStringPattern, bosString);
                    Chats.update({_id: item._id}, {$set: {photoPath:item.photoPath}});
                }
            }
            console.log("Chats: userPicture="+count1+", toUserPicture="+count2);

            //events
            var eventsRecords = Events.find({}).fetch();
            console.log("Events count="+Events.find({}).count());
            count1 = 0;
            for (var i in eventsRecords) {
                var item = eventsRecords[i];
                if (item.headimg && item.headimg.indexOf(bcsString) >= 0) {
                    count1++;
                    item.headimg = item.headimg.replace(bcsStringPattern, bosString);
                    Events.update({_id: item._id}, {$set: {headimg:item.headimg}});
                }
            }
            console.log("Events: headimg="+count1);

            //photos
            var photosRecords = Photos.find({}).fetch();
            console.log("Photos count="+Photos.find({}).count());
            count1 = 0;
            for (var i in photosRecords) {
                count1++;
                var item = photosRecords[i];
                if (item.imageUrl && item.imageUrl.indexOf(bcsString) >= 0) {
                    item.imageUrl = item.imageUrl.replace(bcsStringPattern, bosString);
                    Photos.update({_id: item._id}, {$set: {imageUrl:item.imageUrl}});
                }
                if (item.imageurl && item.imageurl.url && item.imageurl.url.indexOf(bcsString) >= 0) {
                    item.imageurl.url = item.imageurl.url.replace(bcsStringPattern, bosString);
                    Photos.update({_id: item._id}, {$set: {imageurl:item.imageurl}});
                }
            }
            console.log("Photos: imageurl="+count1);

            //posts
            var postsRecords = Posts.find({}).fetch();
            console.log("Posts count="+Posts.find({}).count());
            count1 = 0;
            for (var i in postsRecords) {
                var item = postsRecords[i];
                count1++;
                if (item.userPicture && item.userPicture.indexOf(bcsString) >= 0) {
                    item.userPicture = item.userPicture.replace(bcsStringPattern, bosString);
                    //Posts.update({_id: item._id}, {$set: {userPicture:item.userPicture}});
                }
                if (item.titleImage && item.titleImage.url && item.titleImage.url.indexOf(bcsString) >= 0) {
                    item.titleImage.url = item.titleImage.url.replace(bcsStringPattern, bosString);
                    //Posts.update({_id: item._id}, {$set: {titleImage:item.titleImage}});
                }
                if (item.html && item.html.indexOf(bcsString) >= 0) {
                    item.html = item.html.replace(bcsStringPattern, bosString);
                    //Posts.update({_id: item._id}, {$set: {html:item.html}});
                }
                if (item.replys) {
                    for (var j=0; j<item.replys.length; j++) {
                        if (item.replys[j].userPicture && item.replys[j].userPicture.indexOf(bcsString) >= 0) {
                            item.replys[j].userPicture = item.replys[j].userPicture.replace(bcsStringPattern, bosString);
                        }
                    }
                }
                if (item.images) {
                    for (var j=0; j<item.images.length; j++) {
                        if (item.images[j].url && item.images[j].url.indexOf(bcsString) >= 0) {
                            item.images[j].url = item.images[j].url.replace(bcsStringPattern, bosString);
                        }
                    }
                }
                Posts.update({_id: item._id}, {$set: {userPicture:item.userPicture, titleImage:item.titleImage, html:item.html, replys:item.replys, images:item.images}});
            }
            console.log("Posts: count1="+count1);

            //tags
            var tagsRecords = Tags.find({}).fetch();
            console.log("Tags count="+Tags.find({}).count());
            count1 = 0;
            for (var i in tagsRecords) {
                var item = tagsRecords[i];
                count1++;
                if (item.titleImage && item.titleImage.url && item.titleImage.url.indexOf(bcsString) >= 0) {
                    item.titleImage.url = item.titleImage.url.replace(bcsStringPattern, bosString);
                    //Posts.update({_id: item._id}, {$set: {titleImage:item.titleImage}});
                }
                if (item.userPicture && item.userPicture.indexOf(bcsString) >= 0) {
                    item.userPicture = item.userPicture.replace(bcsStringPattern, bosString);
                    //Posts.update({_id: item._id}, {$set: {titleImage:item.titleImage}});
                }
                if (item.images) {
                    for (var j=0; j<item.images.length; j++) {
                        if (item.images[j].url && item.images[j].url.indexOf(bcsString) >= 0) {
                            item.images[j].url = item.images[j].url.replace(bcsStringPattern, bosString);
                        }
                    }
                }
                Tags.update({_id: item._id}, {$set: {titleImage:item.titleImage, userPicture: item.userPicture, images:item.images}});
            }
            console.log("Tags: count1="+count1);

            //users
            var usersRecords = Meteor.users.find({}).fetch();
            console.log("Meteor.users count="+Meteor.users.find({}).count());
            count1 = 0;
            for (var i in usersRecords) {
                var item = usersRecords[i];
                count1++;
                if (item.profile && item.profile.picture && item.profile.picture.indexOf(bcsString) >= 0) {
                    item.profile.picture = item.profile.picture.replace(bcsStringPattern, bosString);
                    Meteor.users.update({_id: item._id}, {$set: {'profile':item.profile}});
                }
                if (item.profile && item.profile.approves) {
                    for (var j in item.profile.approves) {
                        var subItem = item.profile.approves[j];
                        if (subItem.img && subItem.img.indexOf(bcsString) >= 0) {
                            subItem.img = subItem.img.replace(bcsStringPattern, bosString);
                        }
                    }
                    Meteor.users.update({_id: item._id}, {$set: {'profile':item.profile}});
                }

                if (item.business && item.business.titleImage && item.business.titleImage.indexOf(bcsString) >= 0) {
                    item.business.titleImage = item.business.titleImage.replace(bcsStringPattern, bosString);
                    Meteor.users.update({_id: item._id}, {$set: {'business':item.business}});
                }
                if (item.business && item.business.users) {
                    for (var j in item.business.users) {
                        var subItem = item.business.users[j];
                        if (subItem.userPicture && subItem.userPicture.indexOf(bcsString) >= 0) {
                            subItem.userPicture = subItem.userPicture.replace(bcsStringPattern, bosString);
                        }
                    }
                    Meteor.users.update({_id: item._id}, {$set: {'business':item.business}});
                }
                if (item.business && item.business.bypassers) {
                    for (var j in item.business.bypassers) {
                        var subItem = item.business.bypassers[j];
                        if (subItem.userPicture && subItem.userPicture.indexOf(bcsString) >= 0) {
                            subItem.userPicture = subItem.userPicture.replace(bcsStringPattern, bosString);
                        }
                    }
                    Meteor.users.update({_id: item._id}, {$set: {'business':item.business}});
                }
                if (item.business && item.business.reports) {
                    for (var j in item.business.reports) {
                        var subItem = item.business.reports[j];
                        if (subItem.userPicture && subItem.userPicture.indexOf(bcsString) >= 0) {
                            subItem.userPicture = subItem.userPicture.replace(bcsStringPattern, bosString);
                        }
                        for (var k in item.business.reports[j].images) {
                            var subItem = item.business.reports[j].images[k];
                            if (subItem.url && subItem.url.indexOf(bcsString) >= 0) {
                                subItem.url = subItem.url.replace(bcsStringPattern, bosString);
                            }
                        }
                    }
                    Meteor.users.update({_id: item._id}, {$set: {'business':item.business}});
                }
            }
            console.log("Meteor.users: count="+count1);
        }

        function isObject(obj){
            return (typeof obj=='object');
        }

        function isArray(obj){
            return (typeof obj=='object') && obj.constructor==Array;
        }

        function isFunction(obj){
            return (typeof obj=='function');//&&obj.constructor==Function;
        }

        function isBoolean(obj){
            return (typeof obj=='boolean')&&obj.constructor==Boolean;
        }

        function isNumber(obj){
            return (typeof obj=='number')&&obj.constructor==Number;
        }

        function isString(str){
            return (typeof str=='string')&&str.constructor==String;
        }

        function hasBcsString(string){
            if (string && string.indexOf(bcsString) >= 0) {
                return true;
            } else {
                return false;
            }
        }

        var recurCollection = function(jsonData, name) {
            if (jsonData) {
                for (var key in jsonData) {
                    //console.log("key="+key+", "+JSON.stringify(jsonData[key]));
                    if (jsonData[key] && jsonData[key]!=undefined) {
                        //console.log("!!jsonData["+key+"]="+JSON.stringify(jsonData[key]));
                        if (jsonData[key] && isArray(jsonData[key])) {
                            //console.log("Array");
                            for (var i in jsonData[key]) {
                                var item = jsonData[key][i];
                                if (item && isArray(item)) {
                                    //console.log("!!!Two arrays, "+JSON.stringify(jsonData) +"\n item="+JSON.stringify(item));
                                    recurCollection(item, name+'.'+key+'['+i+']');
                                } else if (isObject(item)) {
                                    recurCollection(jsonData[key][i], name+'.'+key+'['+i+']');
                                } else if (isString(item)) {
                                    if (hasBcsString(item)) {
                                        console.log("!!! Find bcstring: "+name+'.'+key+'['+i+']='+item);
                                    }
                                } else if (isNumber(item)) {
                                    return;
                                } else if (isFunction(item)) {
                                    return;
                                } else if (isBoolean(item)) {
                                    return;
                                } else {
                                    console.log("We don't know the data type: "+name+'.'+key+'['+i+']');
                                }
                            }
                        } else if (isObject(jsonData[key])) {
                            //console.log("Object");
                            recurCollection(jsonData[key], name+'.'+key);
                        } else if (isString(jsonData[key])) {
                            //console.log("String");
                            if (hasBcsString(jsonData[key])) {
                                console.log("!!! Find bcstring: "+name+'.'+key+'='+jsonData[key]);
                            }
                        } else if (isNumber(jsonData[key])) {
                            return;
                        } else if (isBoolean(jsonData[key])) {
                            return;
                        } else if (isFunction(jsonData[key])) {
                            return;
                        } else {
                            //console.log("  jsonData="+JSON.stringify(jsonData));
                            console.log("We don't know the data type 2: "+name+'.'+key+", type="+(typeof jsonData[key])+", jsonData["+key+"]="+JSON.stringify(jsonData[key]));
                        }
                    }
                }
            }
        }

        var checkAllDatabases = function() {
            console.log("checkAllDatabases:bcsStringPattern="+bcsStringPattern+", bcsString="+bcsString+", bosString="+bosString);

            //chatUsers
            var chatUsersRecords = ChatUsers.find({}).fetch();
            console.log("ChatUsers...");
            recurCollection(chatUsersRecords, 'ChatUsers');

            //Chats
            var chatsRecords = Chats.find({}).fetch();
            console.log("Chats...");
            recurCollection(chatsRecords, 'Chats');

            //events
            var eventsRecords = Events.find({}).fetch();
            console.log("Events...");
            recurCollection(eventsRecords, 'Events');

            //photos
            var photosRecords = Photos.find({}).fetch();
            console.log("Photos...");
            recurCollection(photosRecords, 'Photos');

            //posts
            var postsRecords = Posts.find({}).fetch();
            console.log("Posts...");
            recurCollection(postsRecords, 'Posts');

            //tags
            var tagsRecords = Tags.find({}).fetch();
            console.log("Tags...");
            recurCollection(tagsRecords, 'Tags');

            //users
            var usersRecords = Meteor.users.find({}).fetch();
            console.log("Meteor.users...");
            recurCollection(usersRecords, 'Meteor.users');

            console.log("checkAllDatabases() finished!");
        }

        replaceLocation();
        //return checkAllDatabases();
        /*
        for (var i=0; i<1; i++) {
            if (i == 1) {
                bcsStringPattern = bcsStringPattern2;
                bcsString = bcsString2;
                bosString = bosString2;
            }
            replaceToBOS();
            checkAllDatabases();
        }
        */
    });
}
