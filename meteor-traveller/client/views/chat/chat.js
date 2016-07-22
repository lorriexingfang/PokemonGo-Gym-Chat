/**
 * Created by actiontec on 15-6-3.
 */var chat_now_time, chat_show_time;

if (Meteor.isClient) {
    $(window).scroll(function() {
	    return;
        var limit, scrollHeight, scrollTop, windowHeight;
        var chatMessages = $('#chat #message-box #remark');
        scrollTop = $(this).scrollTop();
        scrollHeight = $(document).height();
        windowHeight = $(this).height();

        if ((chatMessages.get(0) != null) && (chatMessages.get(0).scrollTop == 0) && Session.equals('view', 'chat_home')) {
            var _ref, _ref1;
            $('#chat #remark').data('previous-height', ((_ref = $('#chat #remark').get(0)) != null ? _ref.scrollHeight : void 0) - ((_ref1 = $('#chat #remark').get(0)) != null ? _ref1.scrollTop : void 0));
            console.log("chat.js: scrollHeight="+((_ref = $('#chat #remark').get(0)) != null ? _ref.scrollHeight : void 0)+", scrollTop="+((_ref1 = $('#chat #remark').get(0)) != null ? _ref1.scrollTop : void 0));
            limit = Session.get('chat_home_limit') + 18;
            window.chatHistory = true;
            Session.set('chat_home_limit', limit);
            showLoading();
            return $.when(customSubscribe('userChats', Session.get("chat_to_userId"), limit)).done(function() {
                return closeLoading();
            }).fail(function() {
                return closeLoading();
            });
        }else if(scrollTop > scrollHeight -windowHeight -40){
            window.chatHistory = false;
        }
    });
    chat_now_time = void 0;
    chat_show_time = void 0;
    Meteor.startup(function(){
        Meteor.defer(function(){
            Tracker.autorun(function(){
                if (Meteor.userId() && Session.get("chat_to_userId")
                    && Session.get("chat_to_userId")!==''){
                    window.chatHistory = false;
                    var userInfo = mongoChatUsers.findOne({
                        toUserId:Session.get("chat_to_userId"),
                        userId:Meteor.userId()
                    });
                    if (userInfo){
                        var the_id = userInfo._id;
                        mongoChatUsers.update({
                            _id: the_id
                        },{
                            $set:{
                                waitReadCount:0
                            }
                        },function(err){
                            console.log(err);
                        })
                    }
                }
            });
        });
    });
    Template.chat_home.rendered = function() {
        return true;
    };
    Template.chat_home.helpers({
        is_not_system_message: function() {
            if (Session.get("chat_to_userId") === void 0 || Session.get("chat_to_userId") === '') {
                return false;
            } else {
                return true;
            }
        },
        isBusiness: function() {
            return Session.get('chat_home_business');
        },
        page_title: function() {
            if (Session.get("chat_to_userId") === void 0 || Session.get("chat_to_userId") === '')
              return '系统消息';
            
            return getUserName(Session.get("chat_to_userId"), Session.get('chat_home_business'));
        },
        isReply: function() {
            try {
                var toUser;
                if (Session.get('chat_home_business') === true) {
                    return true;
                }
                if (Session.get("chat_to_userId") === Meteor.userId()) {
                    return false;
                }
                /*toUser = Meteor.users.findOne({
                    _id: Session.get("chat_to_userId")
                });*/
                toUser = serverPushedUserInfo.findOne({_id: Session.get("chat_to_userId")});
                
                if(!toUser) {
                    toUser = Meteor.users.findOne({_id: Session.get("chat_to_userId")});
                } 

                if(toUser){
                    if (toUser.profile.isReply === false) {
                        return false;
                    } else {
                        return true;
                    }
                } else {
                    return true;
                }
            }
            catch (err) {
                console.log("err: " + err);
                return true;
            }            
        }
    });
    Template.chat_home.events({
        "click .leftButton": function() {
            return PUB.back();
        }
    });

    Template.chat_home.onDestroyed(function() {
        Session.set("chat_to_userId", void 0);
    });

    Template.chat_home_list.created = function() {
        if (Meteor.userId() === null) {
            return Session.set('view', 'dashboard');
        } else {
            Session.set("chat_to_user", void 0);
            chat_now_time = new Date();
            chat_show_time = void 0;
            return console.log('Template.chat_home_list.created');
        }
    };
    Template.chat_home_list.rendered = function() {
        ChatUploadImage.refresh(Session.get("chat_to_userId"));
    	var chatMessages = $('#chat #message-box');

    	if (device.platform === 'Android') {
    		Meteor.setInterval(function() {
				if (Session.get('chat_home_atBottom')) {
					//console.log("Frank: scrollTop="+chatMessages.get(0).scrollTop+", scrollHeight="+chatMessages.get(0).scrollHeight+", clientHeight="+chatMessages.get(0).clientHeight);
					//chatMessages.scrollTop(chatMessages.get(0).scrollHeight - chatMessages.get(0).clientHeight);
					chatMessages.get(0).scrollTop = chatMessages.get(0).scrollHeight - chatMessages.get(0).clientHeight;
				}
			}, 100);
    	}
        Session.set('message-box-scrolling', 0);
        $('.message-box').css('width', $(window).width()-20);
        //$('.message-box').css('height', $(window).height()-102);
        $('#message-box #remark').bind(((document.ontouchstart !== null) ? 'mousedown' : 'touchstart'), function (e) {
            //if (device.platform === "iOS") {
            Session.set('chat_home_atBottom', false);
            if (document.activeElement.id == 'text') {
                $('#text').blur();
            }
        });
        $('#message-box').scroll(function(e) {
            var limit, scrollHeight, scrollTop, windowHeight;
            var chatMessages = $('#chat #message-box');
            var _ref, _ref1;

            if (document.activeElement.id == 'text') {
                console.log("focusing on text!");
                e.preventDefault();
                e.stopPropagation();
                return false;
            }
            scrollTop = chatMessages.scrollTop();
            //console.log("Frank: scrollTop="+scrollTop+", scrollHeight="+chatMessages.get(0).scrollHeight+", height="+chatMessages.height());

            if ((scrollTop == 0) && Session.equals('view', 'chat_home')) {
                console.log("chat.js: scrollHeight="+((_ref = chatMessages.get(0)) != null ? _ref.scrollHeight : void 0)+", scrollTop="+((_ref1 = chatMessages.get(0)) != null ? _ref1.scrollTop : void 0));
                chatMessages.data('previous-height', ((_ref = chatMessages.get(0)) != null ? _ref.scrollHeight : void 0) - ((_ref1 = chatMessages.get(0)) != null ? _ref1.scrollTop : void 0));
                limit = Session.get('chat_home_limit') + 18;
                window.chatHistory = true;
                Session.set('chat_home_limit', limit);
                showLoading();
                Session.set('chat_home_loading', true);
                return $.when(customSubscribe('userChats', Session.get("chat_to_userId"), limit, function(type, err){
                    if (type === 'ready') {
                        console.log("chat_home_loading ready.");
                        Session.set('chat_home_loading', false);
                    } else if (type === 'stop') {
                        console.log("chat_home_loading stop.");
                        Session.set('chat_home_loading', false);
                    } else if (type === 'err') {
                        console.log("chat_home_loading err!! err = "+err);
                        Session.set('chat_home_loading', false);
                    }
                })).done(function() {
                    return closeLoading();
                }).fail(function() {
                    return closeLoading();
                });
            }else if(scrollTop > scrollHeight -windowHeight -40){
                window.chatHistory = false;
            }
        });
    };
    Template.chat_home_list.events({
        'click .upload-wait': function(e){
          navigator.notification.confirm('您希望对此图片消息的处理？', function(index){
            if(index === 1){
              Chats.remove({_id: $(e.currentTarget).attr('tag')});
              //ChatUploadImage.cancelUploadImage(e.currentTarget.id); 
            }
          }, '提示', ['撤销发送','关闭']);
        },
        'click .upload-error': function(e){
          navigator.notification.confirm('您希望对此图片消息的处理？', function(index){
            if(index === 1){
              ChatUploadImage.reUpload(e.currentTarget.id); 
            }
          }, '提示', ['重新发送','关闭']);
        },
        "click div.comment": function() {
            if (this.postId) {
                Session.set("cancelBubble", true);
                Session.set('partnerId', this.postId);
                Session.set("blackboard_post_id", this.postId);
                Session.set("blackborad_footbar_view", "blackboard_footbar_nav");
                Session.set("document.body.scrollTop", document.body.scrollTop);
                Meteor.setTimeout(function() {
                    Session.set("cancelBubble", false);
                    return 300;
                });
                Session.set("partner_return_view", Session.get("view"));
                return Session.set('view', "partner_detail");
            }
        }
    });
    Template.chat_home_list.helpers({
        user_icon: function(){
          if(Meteor.user().profile.picture)
            return Meteor.user().profile.picture;
          else
            return '/userPicture.png';
        },
        hasMore: function() {
            console.log("chatsHistoryCount="+Session.get("chatsHistoryCount")+", chat_home_limit="+Session.get('chat_home_limit'));
            if (Session.get("chatsHistoryCount") == Session.get('chat_home_limit')) {
                return true;
            } else {
                return false;
            }
        },
        chats: function() {
            var chats, toUser, toUserId, userId;

            if (Session.equals('chat_home_loading', true))
                return Session.get("currentChats") || [];
            userId = Meteor.userId();
            toUserId = Session.get("chat_to_userId");

            /*toUser = Meteor.users.findOne({
                _id: Session.get("chat_to_userId")
            });*/
            toUser = serverPushedUserInfo.findOne({_id: Session.get("chat_to_userId")});

            if(!toUser) {
                toUser = Meteor.users.findOne({_id: Session.get("chat_to_userId")});
            } 

            if (Session.get("chat_to_userId") === void 0 || Session.get("chat_to_userId") === '') {
                chats = Chats.find({
                    $or: [
                        {
                            toUserId: userId,
                            msgType: 'system'
                        }
                    ]
                }, {
                    sort: {
                        createdAt: 1
                    }
                }).fetch();
            } else if (Session.get('chat_home_business') === true) {
                chats = Chats.find({
                    $or: [
                        {
                            userId: toUserId,
                            toUserId: userId
                            //msgType: 'business'
                        }, {
                            userId: userId,
                            toUserId: toUserId
                            //msgType: 'business'
                        }
                    ]
                }, {
                    sort: {
                        createdAt: 1
                    }
                }).fetch();
            } else {
                chats = Chats.find({
                    $or: [
                        {
                            userId: toUserId,
                            toUserId: userId,
                            msgType: {
                                $ne: 'business'
                            }
                        }, {
                            userId: userId,
                            toUserId: toUserId,
                            msgType: {
                                $ne: 'business'
                            }
                        }
                    ]
                }, {
                    sort: {
                        createdAt: 1
                    }
                }).fetch();
            }
            Session.set("chatsHistoryCount", chats.length);
            console.log("chats.length = "+chats.length);
            Session.set("currentChats", chats);
            return chats;
        },
        is_show_time: function(time) {
            var showTime;
            showTime = GetTime0(chat_now_time - time);
            if (showTime === chat_show_time) {
                return false;
            }
            chat_show_time = showTime;
            return true;
        },
        time_diff: function(time) {
            var now, showTime;
            now = new Date();
            showTime = GetTime0(now - time);
            return showTime;
        }
    });

    Template.chat_message_dashboard.created = function() {
        var chatMessages = $('#chat #message-box');
        if (chatMessages && chatMessages.get(0)) {
            var scrollTop = chatMessages.scrollTop();
            var scrollHeight = chatMessages.get(0).scrollHeight;
            var height = chatMessages.height();
            //console.log("created, scrollTop="+scrollTop+", height="+height+", scrollHeight="+scrollHeight);
            if (scrollTop + height >= scrollHeight) {
                Session.set("Scroll-to-bottom", 1);
            } else {
                Session.set("Scroll-to-bottom", 0);
            }
        } else {
            Session.set("Scroll-to-bottom", 1);
        }
        return true;
    };
    Template.chat_message_dashboard.rendered = function() {
        $('.deleteChat').popover({
                html: true,
                placement: "top",
              //  content: 'delete',
                content: "<div  class='deleteComment'>删除</div>",
                trigger: "click"
        });

        var chatMessages = $('#chat #message-box');
        var chatMessages2 = $('#chat #message-box #remark');
        if (!chatMessages.data('computed-height')) {
            $('#chat .message-box').css('width', $(window).width()-20);
            //$('#chat .message-box').css('height', $(window).height()-102);
            console.log("#chat #remark height="+$('#chat #remark').css('height'));
            chatMessages.data('computed-height', 'true');
        }
        var previousScrollTop = chatMessages.data('previous-scrollTop');
        var scrollTop = chatMessages.scrollTop();
        var scrollHeight = chatMessages.get(0).scrollHeight;
        var height = chatMessages.height();
        var isLastChild = false;
        var lastMessage = $('#chat #message-box #remark').children().last();//$('#chat #message-box #remark li::last-child')
        var childs = lastMessage.find('li');
        if (childs.length > 0) {
            for (var i=0; i<childs.length; i++){
                if (childs[i].id == Template.currentData().data._id) {
                    isLastChild = true;
                }
            }
        }

        //console.log("previousScrollTop="+previousScrollTop+", scrollTop="+scrollTop+", scrollheight="+chatMessages.get(0).scrollHeight+", height="+chatMessages.height());
        //console.log("2 previousScrollTop="+previousScrollTop+", scrollTop="+chatMessages2.scrollTop()+", scrollheight="+chatMessages2.get(0).scrollHeight+", height="+chatMessages2.height());
        chatMessages.data('previous-scrollTop', scrollTop);
        if (isLastChild && (Session.get("Scroll-to-bottom"))) {
            console.log("Scroll to bottom, scrollTop="+scrollTop+", height="+height+", scrollHeight="+scrollHeight);
            return chatMessages.stop().scrollTop(chatMessages.get(0).scrollHeight+99999);
        } else if (isLastChild) {
            if (previousScrollTop) {
                //chatMessages.stop().scrollTop(scrollTop);
            }
            return;
        }

        if (!chatMessages.data('previous-height')) {
            console.log("FrankNew: 99999");
            return chatMessages.stop().scrollTop(chatMessages.get(0).scrollHeight+99999);
        } else {
            console.log("FrankNew: scrollHeight="+chatMessages.get(0).scrollHeight+", previous-height="+chatMessages.data('previous-height'));
            return chatMessages.stop().scrollTop(chatMessages.get(0).scrollHeight - chatMessages.data('previous-height'));
        }
    };
    Template.chat_message_dashboard.events({
        "click div.comment": function() {
            var chatMessages = $('#chat #remark');
            if (this.postId) {
                Session.set("cancelBubble", true);
                Session.set('partnerId', this.postId);
                Session.set("blackboard_post_id", this.postId);
                Session.set("blackborad_footbar_view", "blackboard_footbar_nav");
                //Session.set("document.body.scrollTop", document.body.scrollTop);
                Meteor.setTimeout(function() {
                    Session.set("cancelBubble", false);
                    return 300;
                });
                Session.set("partner_return_view", Session.get("view"));
                return Session.set('view', "partner_detail");
            }
        },
       "click .camImage": function() {
     
        takePictureFromCamera(function(cancel, result)
        {
            if (cancel) {}
                //t.$('.camera').html('<img src="camera-icon.png" alt="拍照上传"/>')
                //t.$('.add').html('<img src="plus-icon.png" alt="本地上传"/>')
            else
            { 
                image = {url:result.smallImage, filename:result.filename, URI:result.URI}
                var flashTiming, flashTimingUnread, registrationID, registrationType, toUser, toUserToken, upload_images, userToken; 
                Meteor.subscribe('userToken', Session.get("chat_to_userId"), function() {});
                Meteor.subscribe("userinfo", Session.get("chat_to_userId"), function() {});

                toUser = Meteor.users.findOne({
                    _id: Session.get("chat_to_userId")
                });
                //toUser = serverPushedUserInfo.findOne({_id: Session.get("chat_to_userId")});
                registrationID = Session.get('registrationID');
                registrationType = Session.get('registrationType');
                userToken = {
                    type: registrationType,
                    token: registrationID
                };
                toUserToken = PushToken.findOne({
                    userId: toUser._id
                });
                if (userToken === void 0) {
                    userToken = {};
                }
                if (toUserToken === void 0) {
                    toUserToken = {};
                }
                flashTiming = Session.get("flash_timing");
                flashTimingUnread = Session.get("flash_timing_unread");
              


             var timestamp = new Date().getTime();
                var filename = Meteor.userId()+'_'+timestamp+'.jpg'; 
                  //uploadToS3(filename,results[i],callback);
                
                Meteor.call('getAliyunWritePolicy',filename,image.URI,function(error,result){
                    if(error) {
                      def.reject(error);
                      console.log('getAliyunWritePolicy error: ' + error);
                      if(callback){
                          callback(null);
                      }
                    }
                    console.log('File URI is ' + result.orignalURI);
                    var options = new FileUploadOptions();
                    options.mimeType ="image/jpeg";
                    options.chunkedMode = false;
                    options.httpMethod = "PUT";
                    options.fileName = filename;

                    var uri = encodeURI(result.acceccURI);

                    var headers = {
                      "Content-Type": "image/jpeg",
                      "Content-Md5":"",
                      "Authorization": result.auth,
                      "Date": result.date
                    };
                    options.headers = headers;

                    var ft = new FileTransferBCS();
                    ft.onprogress = function(progressEvent) {
                      if (progressEvent.lengthComputable) {
                        console.log('Loaded ' + progressEvent.loaded + ' Total ' + progressEvent.total);
                        //computeProgressBar(filename, 60*(progressEvent.loaded/progressEvent.total));
                        console.log('Uploaded Progress 1 ' + 60* (progressEvent.loaded / progressEvent.total ) + '%');
                      } else {
                        console.log('Upload ++');
                      }
                    };
                    ft.upload(result.orignalURI, uri, function(e){
                        var filename = result.acceccURI.replace(/^.*[\\\/]/, '');
                        var cdnFileName = "http://data.youzhadahuo.com/" + filename;
                        DEBUG && console.log("cdnFileName = "+cdnFileName);
                        def.resolve({url: cdnFileName});
                        if(callback){
                            //computeProgressBar(filename, 100);
                            callback(cdnFileName);
                        }
                    }, function(e){
                      def.reject(e);
                      console.log('upload error' + e.code );
                      if(callback){
                        callback(null);
                      }
                    }, options,true);
                    
                    Chats.insert({
                    userId: Meteor.user()._id,
                    userToken: userToken,
                    userName: Meteor.user().profile.nike === void 0 || Meteor.user().profile.nike === "" ? Meteor.user().username : Meteor.user().profile.nike,
                    userPicture: Meteor.user().profile.picture,
                    toUserId: toUser._id,
                    toUserToken: toUserToken,
                    toUserName: toUser.profile.nike === void 0 || toUser.profile.nike === "" ? toUser.username : toUser.profile.nike,
                    toUserPicture: toUser.profile.picture,
                    text: false,
                    photoPath: "http://data.youzhadahuo.com/" + filename,
                    isRead: false,
		    msgType:'wifiCard',
                    readTime: void 0,
                    createdAt: new Date()
                });
                chat_now_time = new Date();
                chat_show_time = void 0; 
                    
                    
                  });



            }
         });        
             
		  var chatMessages = $('#chat #message-box');
		  chatMessages.get(0).scrollTop = chatMessages.get(0).scrollHeight+99999;
          
        },
        "click .addImage": function() {
          //ChatUploadImage.test();
          //ChatUploadImage.test(function(image){
          
          ChatUploadImage.upload(9, Session.get("chat_to_userId"), function(image){
            var flashTiming, flashTimingUnread, registrationID, registrationType, toUser, toUserToken, upload_images, userToken; 
            Meteor.subscribe('userToken', Session.get("chat_to_userId"), function() {});
            Meteor.subscribe("userinfo", Session.get("chat_to_userId"), function() {});
                
            toUser = Meteor.users.findOne({
                _id: Session.get("chat_to_userId")
            });
            //toUser = serverPushedUserInfo.findOne({_id: Session.get("chat_to_userId")});
            registrationID = Session.get('registrationID');
            registrationType = Session.get('registrationType');
            userToken = {
                type: registrationType,
                token: registrationID
            };
            toUserToken = PushToken.findOne({
                userId: toUser._id
            });
            if (userToken === void 0) {
                userToken = {};
            }
            if (toUserToken === void 0) {
                toUserToken = {};
            }
            flashTiming = Session.get("flash_timing");
            flashTimingUnread = Session.get("flash_timing_unread");
            Chats.insert({
                userId: Meteor.user()._id,
                userToken: userToken,
                userName: Meteor.user().profile.nike === void 0 || Meteor.user().profile.nike === "" ? Meteor.user().username : Meteor.user().profile.nike,
                userPicture: Meteor.user().profile.picture,
                toUserId: toUser._id,
                toUserToken: toUserToken,
                toUserName: toUser.profile.nike === void 0 || toUser.profile.nike === "" ? toUser.username : toUser.profile.nike,
                toUserPicture: toUser.profile.picture,
                text: false,
                photoPath: image.url,
                photoStatus: image,
                flashTiming: flashTiming,
                flashTimingUnread: flashTimingUnread,
                isRead: false,
		msgType:'wifiCard',
                readTime: void 0,
                createdAt: new Date()
            });
            chat_now_time = new Date();
            chat_show_time = void 0;
          }, function(image){
          	var chat = Chats.findOne({'photoStatus.id': image.id});
          	if (chat) {
          		DEBUG && console.log("chat = "+JSON.stringify(chat));
          		Chats.update({_id: chat._id}, {
          			$unset: {photoStatus: ""},
          			$set: {photoPath: image.url}
          		}, function(err, number) {
          			if (err || number <= 0) {
		        	  console.log('update image in chat history failed!!!');
		        	}
		        });
		        Meteor.setTimeout(function() {
                    $('#'+chat._id).forceLazyLoad();
                    var chatMessages = $('#chat #message-box');
                    chatMessages.get(0).scrollTop = chatMessages.get(0).scrollHeight+99999;
                    return ;
                });
          	}
          });
		  var chatMessages = $('#chat #message-box');
		  chatMessages.get(0).scrollTop = chatMessages.get(0).scrollHeight+99999;
          
        },
        "click div.comment .chatimg": function(e) {
            var images = new Array();
            var chats =  Template.chat_home_list.__helpers.get('chats')();
            chats.forEach(function(item) {
                if (item.photoPath != undefined && item.photoPath != '' && item.photoPath != null) {
                    return images.push(item.photoPath);
                }
            });
            Session.set("images_view_images", images);
            Session.set("images_view_images_selected", e.currentTarget.src);
            Session.set("return_view", Session.get("view"));
            Session.set("document.body.scrollTop", document.body.scrollTop);
            PUB.page("images_view");
        },
        "click div.faceimg": function(e) {
            var userId = Chats.findOne(e.currentTarget.parentNode.id).userId;
            var user = serverPushedUserInfo.findOne({_id: userId});

            if(!user) {
                user = Meteor.users.findOne(userId);
            }

            /*if(Meteor.users.findOne(userId).profile.isBusiness == 1){*/
            if(user && user.profile && user.profile.isBusiness == 1){
                Meteor.call('viewWifiBusiness', userId);
                Session.set('online-view', 'wifiOnlineText');
                Session.set('wifiOnlineId', userId);
                PUB.page("wifiOnline");
            } else {
                Session.set('myview', 'home_detailed');
                PUB.user_home(userId);
                e.stopPropagation();
            }
        },
        "click .deleteComment": function(e){
            chatId = $(e.currentTarget).parent().parent().parent().attr("id");
           Chats.remove({_id: chatId});
            e.preventDefault();
            e.stopPropagation();
        }
    });
    Template.chat_message_dashboard.helpers({
    	isUploading: function(photoStatus) {
    		if (photoStatus != null && photoStatus != undefined) {
    			return true;
    		} else {
    			return false;
    		}
    	},
        ISmsgTypeEx: function(msgTypeExstr) {
    		if (msgTypeExstr == "wifiShare") {
    			return true;
    		} else {
    			return false;
    		}
    	},
    	isUploadError: function(photoStatus) {
    		if (photoStatus.status === 'error') {
    			return true;
    		} else {
    			return false;
    		}
    	},
        m_userPicture: function() {
            if (Meteor.user() && Meteor.user().profile && Meteor.user().profile.isBusiness && Meteor.user().profile.isBusiness === 1 && Session.get('chat_home_business') === true) {
                return Meteor.user().business.titleImage;
            }
            return Meteor.user().profile.picture;
        },
        m_toUserName: function() {
            if (Session.get("chat_to_userId") === void 0 || Session.get("chat_to_userId") === '')
              return '管理员';
            
            return getUserName(Session.get("chat_to_userId"), Session.get('chat_home_business'));
//            var toUser = null;
//            try{
//                if (Session.get("chat_to_userId") === void 0 || Session.get("chat_to_userId") === '') {
//                    return '管理员';
//                } else if (Session.get("chat_to_user") === void 0 || Session.get("chat_to_user") === "") {
//                    toUser = Meteor.users.findOne({
//                        _id: Session.get("chat_to_userId")
//                    });
//                    if (toUser){
//                        Session.set("chat_to_user", toUser);
//                    }
//                }
//            } catch(error){}
//            toUser = Session.get("chat_to_user");
//            if(toUser){
//                if (toUser.profile.isBusiness && toUser.profile.isBusiness === 1 && Session.get('chat_home_business') === true) {
//                    return toUser.profile.business;
//                }
//                if (toUser.profile.nike === void 0 || toUser.profile.nike === "") {
//                    return toUser.username;
//                } else {
//                    return toUser.profile.nike;
//                }
//            } else {
//                return Session.get("chat_to_userName");
//            }
        },
        m_toUserPicture: function() {
            var toUser = null;
            try{
                if (Session.get("chat_to_userId") === void 0 || Session.get("chat_to_userId") === '') {
                    return '';
                } else if (Session.get("chat_to_user") === void 0 || Session.get("chat_to_user") === "") {
                    /*toUser = Meteor.users.findOne({
                        _id: Session.get("chat_to_userId")
                    });*/

                    toUser = serverPushedUserInfo.findOne({_id: Session.get("chat_to_userId")});

                    if(!toUser) {
                        toUser = Meteor.users.findOne({_id: Session.get("chat_to_userId")});                        
                    } 

                    if(toUser){
                        Session.set("chat_to_user", toUser);
                    }
                }
            } catch (error){}
            toUser = Session.get("chat_to_user");
            if (toUser && toUser.profile && toUser.profile.isBusiness && toUser.profile.isBusiness === 1 && Session.get('chat_home_business') === true) {
                return toUser.business.titleImage;
            }
            if (toUser){
                return toUser.profile.picture;
            }
        },
        is_my_say: function(chat) {
            //document.body.scrollTop = document.body.scrollHeight + 60;
            return chat.userId === Meteor.userId();
        }
    });
  
    var isRefreshToolbar = false;
    var refreshToolbar = function(){
      if(isRefreshToolbar && (!!navigator.userAgent.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/))){
        $('.footbar').css('top', window.innerHeight+$(window).scrollTop()-49)
        $("#chat .home .head").css('top', $(window).scrollTop());
        console.log('refresh \'chat_add_toolbar\' position.');
      }
    };
    $(window).scroll(function(){
      //refreshToolbar();
    });
    Template.chat_add_toolbar.helpers({
      isPrevAP: function(){
        console.log(Session.equals('chat_return_view', 'wifiPubWifi'));
        return Session.equals('chat_return_view', 'wifiPubWifi');
      }
    });
    Template.chat_add_toolbar.rendered = function() {
        $('#text').on('keyup input',function(e){
            if ($('#text').val().length) {
                $(".submit").attr("disabled", false);
            } else {
                $(".submit").attr("disabled", "disabled");
            }
            console.log("window.height()="+$(window).height()+", window.innerHeight="+window.innerHeight+", scrollTop="+$(window).scrollTop())
        });
        $('#text').on('touchstart mousedown', function(e){
			e.stopPropagation()
		})
        $("#text").autogrow({
        	maxHeight: 130,
        	postGrowCallback: function(){
				var dif = $(".footbar").outerHeight();
				if (dif <= 54) {
					$("#text").css('padding-top', 5);
					$("#text").css('padding-bottom', 5);
				} else {
					$("#text").css('padding-top', 0);
					$("#text").css('padding-bottom', 0);
				}
				if (dif <= 150) {
					$("#chat .message-box #remark").css('padding-bottom', dif);
					console.log("Frank: Yes, outerHeight="+$(".footbar").outerHeight()+", dif = "+dif);
				} else {
					console.log("Frank: No, outerHeight="+$(".footbar").outerHeight()+", dif = "+dif);
				}
				var chatMessages = $("#chat .message-box");
				chatMessages.get(0).scrollTop = chatMessages.get(0).scrollHeight+99999;
			}
		});
        return true;
    };
    Template.chat_add_toolbar.events({
        "click .addImg": function() {
          //ChatUploadImage.test();
          //ChatUploadImage.test(function(image){
          ChatUploadImage.upload(9, Session.get("chat_to_userId"), function(image){
            var flashTiming, flashTimingUnread, registrationID, registrationType, toUser, toUserToken, upload_images, userToken;
            Meteor.subscribe('userToken', Session.get("chat_to_userId"), function() {});
            Meteor.subscribe("userinfo", Session.get("chat_to_userId"), function() {});
            toUser = Meteor.users.findOne({
                _id: Session.get("chat_to_userId")
            });
            //toUser = serverPushedUserInfo.findOne({_id: Session.get("chat_to_userId")});
            registrationID = Session.get('registrationID');
            registrationType = Session.get('registrationType');
            userToken = {
                type: registrationType,
                token: registrationID
            };
            toUserToken = PushToken.findOne({
                userId: toUser._id
            });
            if (userToken === void 0) {
                userToken = {};
            }
            if (toUserToken === void 0) {
                toUserToken = {};
            }
            flashTiming = Session.get("flash_timing");
            flashTimingUnread = Session.get("flash_timing_unread");
            Chats.insert({
                userId: Meteor.user()._id,
                userToken: userToken,
                userName: Meteor.user().profile.nike === void 0 || Meteor.user().profile.nike === "" ? Meteor.user().username : Meteor.user().profile.nike,
                userPicture: Meteor.user().profile.picture,
                toUserId: toUser._id,
                toUserToken: toUserToken,
                toUserName: toUser.profile.nike === void 0 || toUser.profile.nike === "" ? toUser.username : toUser.profile.nike,
                toUserPicture: toUser.profile.picture,
                text: false,
                photoPath: image.url,
                photoStatus: image,
                flashTiming: flashTiming,
                flashTimingUnread: flashTimingUnread,
                isRead: false,
                readTime: void 0,
                createdAt: new Date()
            });
            chat_now_time = new Date();
            chat_show_time = void 0;
          }, function(image){
          	var chat = Chats.findOne({'photoStatus.id': image.id});
          	if (chat) {
          		DEBUG && console.log("chat = "+JSON.stringify(chat));
          		Chats.update({_id: chat._id}, {
          			$unset: {photoStatus: ""},
          			$set: {photoPath: image.url}
          		}, function(err, number) {
          			if (err || number <= 0) {
		        	  console.log('update image in chat history failed!!!');
		        	}
		        });
		        Meteor.setTimeout(function() {
                    $('#'+chat._id).forceLazyLoad();
                    var chatMessages = $('#chat #message-box');
                    chatMessages.get(0).scrollTop = chatMessages.get(0).scrollHeight+99999;
                    return ;
                });
          	}
          });
		  var chatMessages = $('#chat #message-box');
		  chatMessages.get(0).scrollTop = chatMessages.get(0).scrollHeight+99999;
//            return uploadFiles(function(result) {
//                var flashTiming, flashTimingUnread, registrationID, registrationType, toUser, toUserToken, upload_images, userToken;
//                $('#loading').css('display', '');
//                if (result) {
//                    upload_images = Session.get("upload_images") || [];
//                    upload_images.push({
//                        url: result
//                    });
//                    Session.set("upload_images", upload_images);
//                }
//                $('#loading').css('display', 'none');
//                Meteor.subscribe('userToken', Session.get("chat_to_userId"), function() {});
//                Meteor.subscribe("userinfo", Session.get("chat_to_userId"), function() {});
//                toUser = Meteor.users.findOne({
//                    _id: Session.get("chat_to_userId")
//                });
//                //toUser = serverPushedUserInfo.findOne({_id: Session.get("chat_to_userId")});
//                registrationID = Session.get('registrationID');
//                registrationType = Session.get('registrationType');
//                userToken = {
//                    type: registrationType,
//                    token: registrationID
//                };
//                toUserToken = PushToken.findOne({
//                    userId: toUser._id
//                });
//                if (userToken === void 0) {
//                    userToken = {};
//                }
//                if (toUserToken === void 0) {
//                    toUserToken = {};
//                }
//                flashTiming = Session.get("flash_timing");
//                flashTimingUnread = Session.get("flash_timing_unread");
//                Chats.insert({
//                    userId: Meteor.user()._id,
//                    userToken: userToken,
//                    userName: Meteor.user().profile.nike === void 0 || Meteor.user().profile.nike === "" ? Meteor.user().username : Meteor.user().profile.nike,
//                    userPicture: Meteor.user().profile.picture,
//                    toUserId: toUser._id,
//                    toUserToken: toUserToken,
//                    toUserName: toUser.profile.nike === void 0 || toUser.profile.nike === "" ? toUser.username : toUser.profile.nike,
//                    toUserPicture: toUser.profile.picture,
//                    text: false,
//                    photoPath: result,
//                    flashTiming: flashTiming,
//                    flashTimingUnread: flashTimingUnread,
//                    isRead: false,
//                    readTime: void 0,
//                    createdAt: new Date()
//                });
//                chat_now_time = new Date();
//                chat_show_time = void 0;
//                /*Meteor.setTimeout(function() {
//                    document.body.scrollTop = document.body.scrollHeight;
//                    return 300;
//                });*/
//                return false;
//            });
        },
        "focus #text": function(e) {
            //e.preventDefault();
            //e.stopPropagation();
            if (!!navigator.userAgent.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/)) {
                $(".footbar").css('position', 'absolute');
                //$(".footbar").css('bottom', 'auto');
                //$("#chat .home .head").css('position', 'absolute');
                //isRefreshToolbar = true;
                //refreshToolbar();
            } else {
                //$("#chat #remark").css('padding-bottom', 54);
            }

            var chatMessages = $('#chat #message-box');
            var scrolling;
            chatMessages.data('previous-height', null);

            Session.set('chat_home_atBottom', true);
            if (device.platform === 'Android') {
                console.log("android scrollTop="+chatMessages.get(0).scrollHeight);
                //chatMessages.animate({scrollTop: chatMessages.get(0).scrollHeight+99999}, 1000);
            } else {
                $("#message-box").css("overflow-y", "hidden");
                chatMessages.scrollTop(chatMessages.scrollTop()+1);
                $("#message-box").css("overflow-y", "scroll");
                chatMessages.scrollTop(chatMessages.get(0).scrollHeight+99999);
                Meteor.setTimeout(function() {
                    $('.home .head').css('top', $(document).height() - window.innerHeight);
                    if ($('#message-box #remark').height() <= $(window).height()) {
                        $('#message-box #remark').css('padding-top', $(document).height() - 54 - $('#message-box #remark').height());
                    }
                    console.log("window.height()="+$(window).height()+", window.innerHeight="+window.innerHeight+", scrollTop="+$(window).scrollTop()+", $(document).height()="+$(document).height()+", "+$('#message-box #remark').height())
                }, 0);
            }
        },
        "blur #text": function() {
            console.log("blur...");
            Session.set('chat_home_atBottom', false);
            if (!!navigator.userAgent.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/)) {
                //$(".footbar").css('position', 'fixed');
                $(".footbar").css('top', 'auto');
                $(".footbar").css('bottom', '0px');
                $("#chat .home .head").css('position', 'fixed');
                //$("#chat .home .head").css('top', '0px');
                //isRefreshToolbar = false;
                //refreshToolbar();
                $('.home .head').css('top', 0);
            } else {
                //$("#chat #remark").css('padding-bottom', 0);
            }
            $('#message-box #remark').css('padding-top', 54);
        },
        "click .submit": function() {
            var comment;
            comment = $('#text').val();
            comment = $.trim(comment);
            $('#text').focus();
            if (comment === '') {
                return PUB.toast('请填写内容!');
            } else {
                return $("#new-reply").submit();
            }
        },
        "submit .new-reply": function(e) {
            var chatMessages = $('#chat #message-box');
            var registrationID, registrationType, text, toUser, toUserToken, userToken;
            if (Session.get("chat_to_userId") === void 0 || Session.get("chat_to_userId") === '') {
                window.plugins.toast.showLongBottom('系统消息不能回复!');
                return false;
            }
            text = e.target.text.value;
            if (text === "") {
                window.plugins.toast.showLongBottom('内容不能为空!');
                return false;
            }
            Meteor.subscribe('userToken', Session.get("chat_to_userId"), function() {});
            Meteor.subscribe("userinfo", Session.get("chat_to_userId"), function() {});
            toUser = Meteor.users.findOne({
                _id: Session.get("chat_to_userId")
            });
            //toUser = serverPushedUserInfo.findOne({_id: Session.get("chat_to_userId")});
            registrationID = Session.get('registrationID');
            registrationType = Session.get('registrationType');
            userToken = {
                type: registrationType,
                token: registrationID
            };
            toUserToken = PushToken.findOne({
                userId: toUser._id
            });
            if (toUserToken === void 0) {
                toUserToken = {};
            }
            //chatMessages.data('previous-height', null);
            Chats.insert({
                userId: Meteor.user()._id,
                userToken: userToken,
                userName: Meteor.user().profile.nike === void 0 || Meteor.user().profile.nike === "" ? Meteor.user().username : Meteor.user().profile.nike,
                userPicture: Meteor.user().profile.picture,
                toUserId: toUser._id,
                toUserToken: toUserToken,
                toUserName: toUser.profile.nike === void 0 || toUser.profile.nike === "" ? toUser.username : toUser.profile.nike,
                toUserPicture: toUser.profile.picture,
                text: text,
                isRead: false,
                readTime: void 0,
                createdAt: new Date()
            });
            e.target.text.value = "";
            $('#text').get(0).updateAutogrow();
            chat_now_time = new Date();
            chat_show_time = void 0;
            /*Meteor.setTimeout(function() {
                document.body.scrollTop = document.body.scrollHeight;
                return 300;
            });*/
			chatMessages.get(0).scrollTop = chatMessages.get(0).scrollHeight+99999;
            Session.set('chat_home_limit', Session.get('chat_home_limit')+1);
            return false;
        }
    });
}
