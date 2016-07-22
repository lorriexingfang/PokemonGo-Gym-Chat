/**
 * Created by actiontec on 15-5-19.
 */
var cur_deleted = false;
Template.partner_detail.rendered = function() {
    var toJoin, views;
    cur_deleted = false;
    Session.set("blackboard_post_id", Session.get("partnerId"));
    if (Meteor.user()) {
        post = Posts.findOne({
            _id: Session.get("partnerId")
        });
        if (!post) {
            console.log("partner_detail reandered, no post, maybe deleted");
            return;
        }
        
        toJoin = post.toJoin;
        if (JSON.stringify(toJoin).indexOf(Meteor.userId()) === -1) {
            views = Posts.findOne({
                _id: Session.get("partnerId")
            }).views;
            if (JSON.stringify(views).indexOf(Meteor.userId()) === -1) {
                views.sort();
                if (views.length > 40) {
                    views.length = 39;
                }
                views.push({
                    userId: Meteor.userId(),
                    createdAt: new Date()
                });
                return Posts.update({
                    _id: Session.get("partnerId")
                }, {
                    $set: {
                        views: views
                    }
                });
            }
        }
    }
};
Template.partner_detail.events({
    'click #socialsharing': function() {
        var imagesUrl, num, obj, _i, _len, _ref;
        obj = Posts.findOne({
            _id: Session.get('partnerId')
        });
        imagesUrl = [];
        if (obj.images !== void 0 && obj.images.length > 0) {
            _ref = obj.images;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                num = _ref[_i];
                imagesUrl.push(num.url);
            }
        }
        return Template.public_share_index.__helpers.get('show')();
    },
    'click #btn_back': function() {
        $('#btn_back i').css('color', '#ccc');
        //alert('');
        return window.page.back();
    },
    'click .btn_similar': function(e) {
        Session.set('partnerId', e.currentTarget.id);
        Session.set('blackboard_post_id', e.currentTarget.id);
        Session.set("document.body.scrollTop", document.body.scrollTop);
        return Session.set('view', "partner_detail");
    },
    'click .shop': function(e) {
        var shopId;
        Session.set("cancelBubble", true);
        shopId = e.currentTarget.id;
        Session.set("shopId", shopId);
        Session.set("document.body.scrollTop", document.body.scrollTop);
        Meteor.setTimeout(function() {
            Session.set("cancelBubble", false);
            return 300;
        });
        return PUB.page("shop");
    },
    "click .userHome": function(e) {
        var userId;
        Session.set("cancelBubble", true);
        userId = e.currentTarget.id;
        Meteor.setTimeout(function() {
            Session.set("cancelBubble", false);
            return 300;
        });
        return PUB.user_home(userId);
    },
    "click .photo img": function(e) {
        var images, post;
        Session.set("cancelBubble", true);
        post = Posts.findOne({
            _id: e.currentTarget.id
        });
        images = new Array();
        post.images.forEach(function(item) {
            return images.push(item.url);
        });
        Session.set("images_view_images", images);
        Session.set("images_view_images_selected", e.currentTarget.src);
        Session.set("document.body.scrollTop", document.body.scrollTop);
        PUB.page("images_view");
        return Meteor.setTimeout(function() {
            Session.set("cancelBubble", false);
            return 300;
        });
    },
    "click .viewerList": function(e) {
        var postId;
        Session.set("cancelBubble", true);
        postId = e.currentTarget.id;
        Session.set("viewerId", postId);
        PUB.page("viewers");
        return Meteor.setTimeout(function() {
            Session.set("cancelBubble", false);
            return 300;
        });
    },
    "click .report": function(e) {
        Session.set('reportPostId', e.currentTarget.id);
        return PUB.page("report");
    },
    "click #messageBar": function(e) {
        $('#messageBar div:first-child').show();
        $('#likeBar div:first-child').hide();
        $('#messageContent').show();
        $('#likeContent').hide();
    },
    "click #likeBar": function(e) {
        $('#likeBar div:first-child').show();
        $('#messageBar div:first-child').hide();
        $('#messageContent').hide();
        $('#likeContent').show();
    }

});
Template.partner_detail.helpers({
    showFoot: function() {
        return Session.get("blackborad_footbar_view") === "blackboard_footbar_nav";
    },
    joins: function(j) {
        if (j.length >= 5) {
            j.length = 5;
        }
        return j;
    },
    looks: function(j, v) {
        var n;
        if (j.length >= 5) {
            return [];
        } else {
            n = 5 - j.length;
            if (v.length > n) {
                v.length = n;
            }
            return v;
        }
    },
    time_diff: function(created) {
        return GetTime0(new Date() - created);
    },
    format_day: function(day, n) {
        var today;
        if (isNaN(n)) {
            return day;
        } else {
            today = new Date(day);
            today.setDate(today.getDate() + Math.abs(n));
            return day + ' ~ ' + today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate();
        }
    },
    get_face: function(uid) {
        var user = serverPushedUserInfo.findOne({_id: uid});

        if(!user) {
            Meteor.subscribe("userinfo", uid);
            user = Meteor.users.findOne(uid);
        }

        /*Meteor.subscribe("userinfo", uid);
        if (Meteor.users.findOne(uid) && Meteor.users.findOne(uid).profile && Meteor.users.findOne(uid).profile.picture) {
            return Meteor.users.findOne(uid).profile.picture;
        } else {
            return 'userPicture.png';
        }*/
        if(user && user.profile && user.profile.picture) {
            return user.profile.picture;
        }
        else {
            return 'userPicture.png';
        }
    },
    views: function(v) {
        if (v) {
            return v;
        } else {
            return 0;
        }
    },
    replys_count: function(r) {
        if (r) {
            return r.length;
        } else {
            return 0;
        }
    },
/*  
 * commented out by Peng Zhu <pezhu@actintec.com>
 * date: 2015-08-11
 * changelog: to calculate the view times, we need to include the viewd and joined
 *   
    view_times: function(times) {
        if (times) {
            return times.length;
        } else {
            return 0;
        }
    },  */  
    view_times: function(j, v) { /* added by Peng Zhu 2015-08-11  */
        if (j && v) {
            return (j.length + v.length);
        }
        else if (j) {
            return j.length;
        }
        else if(v) {
            return v.length
        }
        else {
            return 0;
        }
    },
    partner: function() {
        ptner = Posts.findOne({
            _id: Session.get('partnerId')
        });
        if (!ptner && cur_deleted === false) {
            cur_deleted = true;
            console.log("当前搭伙已删除");
            PUB.page("partner_finding");
            PUB.toast("当前搭伙已删除！");            
        }
        return ptner;
    },
    to_count: function(obj){
        try{
            return obj.count();
        }catch(e){
            return "0";
        }
    },
    similar_partners: function() {
        var query, t, tags, _i, _len,similar_partners;
        console.log(Session.get('partnerId'))
        tags = Posts.findOne({
            _id: Session.get('partnerId')
        }).tags;
        if (tags.length > 0) {
            query = [];
            for (_i = 0, _len = tags.length; _i < _len; _i++) {
                t = tags[_i];
                query.push(t.tag);
            }
            similar_partners = Posts.find({
                type: 'pub_board',
                _id: {
                    "$ne": Session.get('partnerId')
                },
                'tags.tag': {
                    '$in': query
                }
            }, {
                limit: 3,
                sort: {
                    createdAt: -1
                }
            });
            similar_partners_num = similar_partners.count();
            Session.set('similar_partners_num',similar_partners_num)
            console.log(similar_partners_num)
            return similar_partners;
        } else {
            return [];
        }
    },
    similar_partners_num:function(){
        return Session.get('similar_partners_num')
    },
    showShop: function(id) {
        if (id === void 0 || id === '' || id === null) {
            return false;
        } else {
            return true;
        }
    },
    is_title_null: function(title) {
        if (title === void 0 || title === '') {
            return true;
        } else {

        }
    }
});