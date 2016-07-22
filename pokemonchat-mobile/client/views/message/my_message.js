/**
 * Created by actiontec on 15-6-2.
 */
if (Meteor.isClient) {
    Template.my_message.rendered = function() {
        if (Meteor.userId() === null) {
            return Session.set('view', 'my_message_guest');
        }
    };
    Template.my_message.helpers({
        manage: function() {
            return Meteor.user() && Meteor.user().profile && Meteor.user().profile.isAdmin === 1;
        }
    });
    Template.my_message.events({
        "click .button_left": function() {
            return window.page.back();
        },
        'click #sendMessage': function() {
            return PUB.page('myu_message_send_group_message');
        }
    });
    Template.my_message_tmp_say_list.helpers({
        time_diff: function(time) {
            var now, showTime;
            now = new Date();
            showTime = GetTime0(now - time);
            if (showTime === "0秒前") {
                return "刚刚";
            } else {
                return showTime;
            }
        },
        is_wait_msg: function(count) {
            return count > 0;
        },
        messageList: function() {
            return ChatUsers.find({
                $or: [
                    {
                        userId: Meteor.userId(),
                        msgType: {
                            $ne: 'system'
                        }
                    }
                ]
            }, {
                sort: {
                    lastTime: -1
                }
            }).fetch();
        },
        isBussiness: function(msgTypeEx) {
            if (msgTypeEx === 'business') {
                return true;
            } else {
                return false;
            }
        },
        isSystem: function(msgTypeEx) {
            if (msgTypeEx === 'system' || msgTypeEx === 'wifiboard') {
                return true;
            } else {
                return false;
            }
        },
        /*sayListsEx: function() {
            var list, updateSystem;
            list = ChatUsers.find({
                userId: Meteor.userId(),
                msgTypeEx: 'system'
            }, {
                sort: {
                    username: 1
                }
            }).fetch();
            updateSystem = function(name) {
                try {
                    var exist, item, user, _i, _len;
                    user = Meteor.users.findOne({
                        username: name
                    });
                    if (!user)
                        return;
                    exist = false;
                    for (_i = 0, _len = list.length; _i < _len; _i++) {
                        item = list[_i];
                        if (item.toUserId === user._id) {
                            exist = true;
                            break;
                        }
                    }
                    if (!exist) {
                        return list.push({
                            userId: Meteor.userId(),
                            userName: Meteor.user().profile.nike ? Meteor.user().profile.nike : Meteor.user().username,
                            userPicture: Meteor.user().profile.picture ? Meteor.user().profile.picture : '/userPicture.png',
                            toUserId: user._id,
                            toUserName: user.profile.nike,
                            toUserPicture: user.profile.picture,
                            waitReadCount: 0,
                            lastText: '[暂无消息]',
                            lastTime: new Date(),
                            msgTypeEx: 'system'
                        });
                    }
                }
                catch(e) {
                    console.log("RDBG updateSystem exception: " + e);
                }
            };
            updateSystem(TRAVELLER_HELPER);
            updateSystem(TRAVELLER_BELL);
            updateSystem(TRAVELLER_MESSAGE);
            updateSystem(TRAVELLER_NEWS);
            return list;
        },
        sayListsExEx: function() {
            return ChatUsers.find({
                userId: Meteor.userId(),
                msgTypeEx: 'business'
            }, {
                sort: {
                    username: 1
                }
            });
        },
        sayLists: function() {
            return ChatUsers.find({
                userId: Meteor.userId(),
                msgTypeEx: {
                    $nin: ['system', 'business']
                },
                msgType: {
                    $ne: 'system'
                }
            }, {
                sort: {
                    lastTime: -1
                }
            });
        },*/
        systemMsg: function(obj) {
            if (obj.msgType === void 0 || obj.msgType !== 'system') {
                return false;
            } else {
                return true;
            }
        },
        systemExMsg: function(obj) {
            if (obj.msgTypeEx === void 0 || obj.msgTypeEx !== 'system') {
                return false;
            } else {
                return true;
            }
        },
        noData: function(obj) {
            if (obj != undefined) {
                return obj.length <= 0;
            } else {
                return true;
            }
        }
    });
    Template.my_message_tmp_say_list.events({
        "click li": function(e) {
            var the_id = $(e.currentTarget).attr('chatUserId')
            if ($(e.currentTarget).attr('tag') === 'wifiboard') {
                var wifiID = $(e.currentTarget).attr('wifiID');
                Template.wifiPubWifi.__helpers.get('open')(wifiID);
            } else if ($(e.currentTarget).attr('tag') === 'business') {
                Session.set('chat_home_business', true);
            } else {
                Session.set('chat_home_business', false);
            }
            mongoChatUsers.update({
                _id: the_id
            },{
                $set:{
                    waitReadCount:0
                }
            },function(err){
                console.log(err);
            })
            if ($(e.currentTarget).attr('tag') === 'wifiboard') {
                return;
            }
            Session.set("chat_to_userId", e.currentTarget.id);
            Session.set("chat_return_view", Session.get("view"));
            return PUB.page("chat_home");
        }
    });
    Template.myu_message_send_group_message.events({
        "click .button_left": function() {
            return PUB.back();
        },
        "submit #send_group_message_form": function(e) {
            var isTest, parameters, target, text;
            target = e.target.target.value;
            text = e.target.comment.value;
            parameters = e.target.parameters.value;
            isTest = e.target.isTest.checked;
            if (parameters !== '') {
                parameters = eval('(' + parameters + ')');
            }
            if (text === "" || target === "") {
                PUB.toast("请完整填写表单!");
            } else if (Meteor.user().profile && Meteor.user().profile.isAdmin === 1) {
                if (confirm('您确定要群发消息吗？')) {
                    Meteor.call('sendGroupMessage', text, target, parameters, isTest);
                    PUB.toast("发送成功！");
                }
            } else {
                PUB.toast("您不是管理员");
            }
            return false;
        }
    });
    Template.my_message_guest.events({
        'click .my_message_guest': function() {
            return Session.set('view', 'dashboard');
        }
    });
}
