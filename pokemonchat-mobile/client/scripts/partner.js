/**
 * Created by actiontec on 15-5-22.
 */
var themels;

if (Meteor.isClient) {
    Session.setDefault('pview', 'partner_about');
    $(window).scroll(function() {
      var limit, scrollHeight, scrollTop, windowHeight;
      scrollTop = $(this).scrollTop();
      scrollHeight = $(document).height();
      windowHeight = $(this).height();

      if(scrollTop >= scrollHeight - windowHeight && Session.equals('view', 'pub_board')){
        if(Session.equals('pview', 'partner_about')){
          $load_more_partner_about = $('#load-more-partner-about')
          var geolocation = Session.get('location');
          var lnglat = geolocation?[geolocation.longitude, geolocation.latitude]:[0, 0];

          $load_more_partner_about.html('加载中，请稍候...')
          Session.set("partner_about_limit", Session.get("partner_about_limit")+10);
          $.when(
            customSubscribe('posts_about', lnglat, Session.get("partner_about_limit"))
          ).done(function(){
            $load_more_partner_about.html('上拉加载更多')
          }).fail(function(){
            $load_more_partner_about.html('上拉加载更多')
          });
        }else if(Session.equals('pview', 'partner_hits')){
          $load_more_partner_hits = $('#load-more-partner-hits')
          $load_more_partner_hits.html('加载中，请稍候...')
          Session.set("partner_hits_limit", Session.get("partner_hits_limit")+10);
          $.when(
            customSubscribe('posts_pub_board', Session.get("partner_hits_limit"))
          ).done(function(){
            $load_more_partner_hits.html('上拉加载更多')
          }).fail(function(){
            $load_more_partner_hits.html('上拉加载更多')
            });
        }
      }
    });

    themels = [
        {
            _id: '3PFjFHbFA5jbNq26Q',
            tag: '自驾',
            img: '/partner/theme.5.jpg',
            title: '自驾旅行'
        }, {
            _id: '3mo9jcJ58uy2JArma',
            tag: '徒步',
            img: '/partner/theme.4.jpg',
            title: '徒步旅行'
        }, {
            _id: 'FwywxYzvEd4te3oDh',
            tag: '租车',
            img: '/partner/theme.6.jpg',
            title: '租车旅行'
        }, {
            _id: 'cr9qZTFBYYHrXxgHR',
            tag: '摄影',
            img: '/partner/theme.3.jpg',
            title: '摄影旅行'
        }, {
            _id: 'qfia5RtaH7vv4jWyw',
            tag: '露营',
            img: '/partner/theme.2.jpg',
            title: '露营旅行'
        }, {
            _id: 'yQSYfKfKWJ2pRt8aL',
            tag: '户外',
            img: '/partner/theme.1.jpg',
            title: '户外旅行'
        }
    ];
    Template.partner.helpers({
        themels: function() {
            return themels;
        },
        groups: function() {
            if (Session.get('data_partner_groups')) {
                return Session.get('data_partner_groups');
            } else {
                return Tags.find({
                    parent: '组团主题'
                }, {
                    limit: 3
                });
            }
        },
        latest_find_partners: function() {
            var posts;
            posts = Posts.find({
                type: 'pub_board'
            }, {
                sort: {
                    createdAt: -1
                },
                limit: 3
            });
            if (posts.count() <= 0) {
                return getLatestFindPartner();
            } else {
                return posts;
            }
        },
        time_diff: function(created) {
            return GetTime0(new Date() - created);
        },
        get_face: function(uid) {
            /*Meteor.subscribe("userinfo", uid);
            if (Meteor.users.findOne(uid) && Meteor.users.findOne(uid).profile && Meteor.users.findOne(uid).profile.picture) {
                return Meteor.users.findOne(uid).profile.picture;
            } else {
                return 'userPicture.png';
            }*/
            var user = serverPushedUserInfo.findOne({_id: uid});

            if(!user) {
                user = Meteor.subscribe("userinfo", uid);
                user = Meteor.users.findOne(uid);                
            }

            if(user && user.profile && user.profile.picture) {
                return user.profile.picture;
            }
            else {
                return 'userPicture.png';
            }
        }
    });
    Template.partner.events({
        'click #add': function() {
            if (Meteor.user() === null) {
                window.plugins.toast.showLongBottom('请登录后发布!');
                Session.set("login_return_view", Session.get("view"));
                PUB.page("dashboard");
                return false;
            } else {
                Session.set("shopId", '');
                Session.set("upload_images", new Array());
                Session.set("add_partner_type", "add");
                Session.set("add_partner_id", '');
                return PUB.page("add_partner");
            }
        },
        'click .finding_partners': function() {
            if (Session.get("cancelBubble")) {
                return;
            }
            Session.set('pview', 'partner_hits');
            Session.set('partner_finding_return_view', Session.get("view"));
            return Session.set('view', 'partner_finding');
        },
        'click .gravatar,.summary': function(e) {
            Session.set("cancelBubble", true);
            Session.set('partnerId', e.currentTarget.id);
            Session.set("blackboard_post_id", e.currentTarget.id);
            Session.set("blackborad_footbar_view", "blackboard_footbar_nav");
            Session.set("document.body.scrollTop", document.body.scrollTop);
            Meteor.setTimeout(function() {
                Session.set("cancelBubble", false);
                return 300;
            });
            Session.set("partner_return_view", Session.get("view"));
            return Session.set('view', "partner_detail");
        },
        'click #themels li': function(e) {
            Session.set('themeId', e.currentTarget.id);
            Session.set('tag', e.currentTarget.getAttribute('tag'));
            Session.set("partner_theme_return_view", Session.get("view"));
            return Session.set("view", "partner_theme");
        },
        'click #group_themels li': function(e) {
            Session.set('content', e.currentTarget.id);
            Session.set("document.body.scrollTop", document.body.scrollTop);
            return PUB.page("activity_detail");
        }
    });
    Template.partner_finding.rendered = function() {
        if (Session.get('pview') === void 0) {
            Session.set('pview', 'partner_about');
        }
        return $('#' + Session.get('pview')).css('border-bottom', '2px solid #00a1e9');
    };
    Template.partner_finding.events({
        'click #search_posts': function() {
            return PUB.page("searching");
        },
        'click #publish_posts': function() {
            if (Meteor.user() === null) {
                PUB.toast('请登录后发布!');
                PUB.page("dashboard");
                return false;
            } else {
                Session.set("add_partner_type", 'add');
                return Session.set('view', 'add_partner');
            }
        },
        'click #btn_back': function() {
            return window.page.back();
        },
        'click #btn_report': function() {
            Session.set('rview', 'partnerReport');
            return PUB.page("reportList");
        },
        'click .btn-group-justified .btn-group': function(e) {
            //$('.btn-group').css('border-bottom', 'none');
            //$('#' + e.currentTarget.id).css('border-bottom', '2px solid #00a1e9');
            if (e.currentTarget.id === "partner_new") {
                Session.set('postType', 'local_service');
            } else {
                Session.set('postType', 'pub_board');
            }
            if (e.currentTarget.id === 'partner_new') {
                return Session.set('pview', 'wifiOffline');
            } else {
                return Session.set('pview', e.currentTarget.id);
            }
        }
    });
    Template.partner_finding.helpers({
        isPview: function(val){
          if(Session.get('pview') === '' || Session.get('pview') === undefined){
            if(val === 'partner_hits')
              return true;
          }

          return Session.equals('pview', val);
        },
        pview: function() {
            if (Session.get('pview' === '' || Session.get('pview' === void 0))) {
                return 'partner_hits';
            } else {
                return Session.get('pview');
            }
        },
        admin: function(v) {
            return v === 1;
        },
        notadmin: function(v) {
            return v !== 1;
        },
        user: function() {
            return Meteor.user();
        }
    });
    Template.partner_hits.created = function() {
        return Session.set("partner_hits_limit", 10);
    };
    Template.partner_hits.rendered = function() {
        Session.set('partner_hits_loading', true);
        $.when(
          customSubscribe('posts_pub_board', Session.get("partner_hits_limit"))
        ).done(function(){
          Session.set('partner_hits_loading', false);
        }).fail(function(){
          Session.set('partner_hits_loading', false);
        });
    };
    Template.partner_hits.helpers({
        loading: function(){
          return Session.equals('partner_hits_loading', true);
        },
        data: function(obj){
          return obj.count() > 0;
        },
        lists: function() {
            return Posts.find({
                type: 'pub_board'
            }, {
                sort: {
                    createdAt: -1
                },
                limit: Session.get("partner_hits_limit")
            });
        }
    });
    Template.partner_about.created = function() {
        // 发搭伙的提示说明
        popup('partnerPopup');
        Session.set("partner_about_limit", 10);
    };
    Template.partner_about.rendered = function() {
        Session.set('partner_about_loading', true);
        var geolocation = Session.get('location');
        var lnglat = geolocation?[geolocation.longitude, geolocation.latitude]:[0, 0];
        $.when(
          customSubscribe('posts_about', lnglat, Session.get("partner_about_limit"))
        ).done(function(){
          Session.set('partner_about_loading', false);
        }).fail(function(){
          Session.set('partner_about_loading', false);
        });
    };
    Template.partner_about.helpers({
        loading: function(){
          return Session.equals('partner_about_loading', true);
        },
        data: function(obj){
          return obj.count() > 0;
        },
        lists: function() {
          var geolocation, lnglat;
          geolocation = Session.get('location');
          lnglat = [0, 0];
          if (geolocation) {
              lnglat = [geolocation.longitude, geolocation.latitude];
          }
          return Posts.find({
              type: "pub_board",
              "location.coordinates": {
                  $near: lnglat,
                  $maxDistance: 60 / 111.12
              }
          }, {
              sort: {
                  createdAt: -1
              },
              limit: Session.get("partner_about_limit")
          });
        }
    });
    Template.partner_new.lists = function() {
        return getPostsNew();
    };
    Template.partner_theme.rendered = function() {
        $('#theme_background').css('min-height', $(window).height());
        $('#theme_background').css('width', $(window).width());
    };
    Template.partner_theme.helpers({
        notes: function() {
            var notes;
            return notes = Posts.find({
                type: 'notes',
                tags: {
                    $in: [Session.get('tag')]
                }
            }, {
                sort: {
                    createdAt: -1
                },
                limit: 1
            });
        },
        theme: function() {
            return Tags.findOne({
                '_id': Session.get('themeId')
            }, {
                limit: 6
            });
        },
        lists: function() {
            var shopId;
            if (Session.get("view" === "shop")) {
                shopId = Session.get("shopId");
                return Posts.find({
                    type: 'pub_board',
                    "tags.tag": Session.get('tag'),
                    shopId: shopId
                }, {
                    sort: {
                        createdAt: -1
                    },
                    limit: 50
                });
            } else {
                return Posts.find({
                    type: 'pub_board',
                    "tags.tag": Session.get('tag')
                }, {
                    sort: {
                        createdAt: -1
                    },
                    limit: 50
                });
            }
        },
        showAd: function(id) {
            if (id === void 0 || id === '') {
                return false;
            } else {
                return true;
            }
        }
    });
    Template.partner_theme.events({
        "click #btn_back": function() {
            return window.page.back();
        },
        "click .notes_title": function(e) {
            Session.set('articleType', 'notes');
            return PUB.page('notes_index', {
                tag: e.currentTarget.id
            });
        },
        "click .noets_first": function(e) {
            Session.set('articleType', 'notes');
            return PUB.page('notes_index', {
                tag: e.currentTarget.id
            });
        },
        "click #add": function() {
            if (Meteor.user() === null) {
                window.plugins.toast.showLongBottom('请登录后发布!');
                PUB.page("dashboard");
                return false;
            } else {
                Session.set("shopId", '');
                Session.set("upload_images", new Array());
                return PUB.page("event_2015_01_index");
            }
        },
        "click .lists li": function(e) {
            Session.set('content', e.currentTarget.id);
            Session.set("return_view", "partner_theme");
            Session.set("document.body.scrollTop", document.body.scrollTop);
            return PUB.page("activity_detail");
        }
    });
    Template.theme_list.helpers({
        get_distance: function(obj) {
            var location;
            location = Session.get('location');
            if (obj.isCustomCity === true || obj.isCustomCity === void 0) {
                return '';
            } else if (location && obj.location.coordinates !== [0, 0]) {
                return distance(location.longitude, location.latitude, obj.location.coordinates[0], obj.location.coordinates[1]);
            } else {
                return '';
            }
        },
        show_distance: function() {
            return Session.get("pview") === "partner_about";
        },
        is_admin: function() {
            if (Meteor.user() && (Meteor.user().profile.isAdmin === 1)) {
                return true;
            }
            return false;
        },
        time_diff: function(created) {
            return GetTime0(new Date() - created);
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
        get_face: function(uid) {
            /*Meteor.subscribe("userinfo", uid);
            if (Meteor.users.findOne(uid) && Meteor.users.findOne(uid).profile && Meteor.users.findOne(uid).profile.picture) {
                return Meteor.users.findOne(uid).profile.picture;
            } else {
                return 'userPicture.png';
            }*/
            var user = serverPushedUserInfo.findOne({_id: uid});

            if(!user) {
                user = Meteor.subscribe("userinfo", uid);
                user = Meteor.users.findOne(uid);                
            } 

            if(user && user.profile && user.profile.picture) {
                return user.profile.picture;
            }
            else {
                return 'userPicture.png';
            }
        },
        showShop: function(id) {
            if (id === void 0 || id === '' || id === null) {
                return false;
            } else {
                return true;
            }
        },
        viewerisjoin: function(id) {
            if (id === false || id === void 0 || id === '') {
                return false;
            } else {
                return true;
            }
        },
        is_my: function(obj) {
            return obj.userId === Meteor.userId();
        },
        is_title_null: function(title) {
            if (title === void 0 || title === '') {
                return true;
            } else {
                return false;
            }
        }
    });
    Template.theme_list.events({
        "click .delete": function(e) {
            e.stopPropagation();
            return PUB.confirm("你确定要删除吗？", function() {
                return Meteor.call("removePost", e.currentTarget.id, function() {});
            });
        },
        'click .edit': function(e) {
            e.stopPropagation();
            Session.set("shopId", '');
            Session.set("upload_images", new Array());
            Session.set("add_partner_id", e.currentTarget.id);
            Session.set("add_partner_type", "edit");
            return PUB.page("add_partner");
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
        'click .partner_lists': function(e) {
            if (Session.get("cancelBubble")) {
                return;
            }
            Session.set('partnerId', e.currentTarget.id);
            Session.set("blackboard_post_id", e.currentTarget.id);
            Session.set("blackborad_footbar_view", "blackboard_footbar_nav");
            Session.set("return_view", "partner_finding");
            Session.set("document.body.scrollTop", document.body.scrollTop);
            Session.set("partner_return_view", Session.get("view"));
            return Session.set('view', "partner_detail");
        },
        'click .shop': function(e) {
            var shopId;
            Session.set("cancelBubble", true);
            shopId = e.currentTarget.id;
            Session.set("shopId", shopId);
            Session.set("return_view", "partner_finding");
            Meteor.setTimeout(function() {
                Session.set("cancelBubble", false);
                return 300;
            });
            return PUB.page("shop");
        },
        "click .photo img": function(e) {
            var images, post;
            Session.set("cancelBubble", true);
            post = Posts.findOne({
                _id: e.currentTarget.parentNode.parentNode.id
            });
            images = new Array();
            post.images.forEach(function(item) {
                return images.push(item.url);
            });
            Session.set("images_view_images", images);
            Session.set("images_view_images_selected", e.currentTarget.src);
            Session.set("return_view", Session.get("view"));
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
            Meteor.setTimeout(function() {
                Session.set("cancelBubble", false);
                return 300;
            });
            return PUB.page("viewers");
        },
        'click .reportNumber': function(e) {
            Session.set("cancelBubble", true);
            Session.set('reportPostId', e.currentTarget.id);
            PUB.page("reason");
            return Meteor.setTimeout(function() {
                Session.set("cancelBubble", false);
                return 300;
            });
        }
    });
    Template.theme_list.rendered = function() {
        return Session.set("cancelBubble", false);
    };
    Template.partner.helpers({
        event_2015_01: function() {
            return Template.event_2015_01_index.__helpers.get('is_valid')();
        }
    });
    Template.partner.events({
        "click .activities": function() {
            return PUB.page("partner_activities");
        }
    });
    Template.partner_activities.helpers({
        event_2015_01: function() {
            return Template.event_2015_01_index.__helpers.get('is_valid')();
        },
        lists: function() {
            return Posts.find({
                type: 'activity'
            }, {
                sort: {
                    createdAt: -1
                }
            });
        }
    });
    Template.partner_activities.events({
        "click #btn_back": function() {
            return window.page.back();
        },
        'click li.event_2015-01': function() {
            if (Meteor.user() === null) {
                window.plugins.toast.showLongBottom('请登录后发布!');
                Session.set("login_return_view", Session.get("view"));
                PUB.page("dashboard");
                return false;
            } else {
                Session.set("shopId", '');
                return PUB.page("event_2015_01_index");
            }
        },
        "click .lists li.lists_li": function(e) {
            Session.set('activityId', e.currentTarget.id);
            Session.set("partnerId", e.currentTarget.id);
            Session.set("blackboard_post_id", e.currentTarget.id);
            Session.set("blackborad_footbar_view", "blackboard_footbar_nav");
            Session.set("document.body.scrollTop", document.body.scrollTop);
            return PUB.page("activity_content");
        },
        "click .activity_img li": function(e) {
            Session.set('activityId', e.currentTarget.id);
            return PUB.page("activity_detail");
        }
    });
    Template.activity_detail.helpers({
        content: function() {
            return Session.get('content');
        },
        activityDetail: function() {
            return Tags.findOne({
                '_id': Session.get('activityId')
            });
        }
    });
    Template.activity_detail.events({
        "click #btn_back": function() {
            return PUB.back();
        }
    });
    Template.activity_detail.rendered = function() {
        return $(window).scrollTop(0);
    };
    Template.viewers.events({
        'click #btn_back': function() {
            return PUB.back();
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
        }
    });
    Template.viewers.helpers({
        get_face: function(uid) {
        /*Meteor.subscribe("userinfo", uid);
            if (Meteor.users.findOne(uid) && Meteor.users.findOne(uid).profile && Meteor.users.findOne(uid).profile.picture) {
                return Meteor.users.findOne(uid).profile.picture;
            }*/
            var user = serverPushedUserInfo.findOne({_id: uid});

            if(!user) {
                user = Meteor.subscribe("userinfo", uid);
                user = Meteor.users.findOne(uid);
            } 

            if(user && user.profile && user.profile.picture) {
                return user.profile.picture;
            }
            else {
                return 'userPicture.png';
            }
        },
        toJoin: function() {
            return Posts.findOne({
                _id: Session.get("viewerId")
            }).toJoin;
        },
        views: function() {
            return Posts.findOne({
                _id: Session.get("viewerId")
            }).views;
        }
    });
    Template.partner_footbar_to_join.events({
        'click #to_join': function() {
            var arr, item, toJoin, views, _i, _len;
            if (Meteor.user()) {
                toJoin = Posts.findOne({
                    _id: Session.get("partnerId")
                }).toJoin;
                if (JSON.stringify(toJoin).indexOf(Meteor.userId()) === -1) {
                    toJoin.sort();
                    toJoin.push({
                        userId: Meteor.userId(),
                        createdAt: new Date()
                    });
                    Posts.update({
                        _id: Session.get("partnerId")
                    }, {
                        $set: {
                            toJoin: toJoin
                        }
                    });
                    views = Posts.findOne({
                        _id: Session.get("partnerId")
                    }).views;
                    if (JSON.stringify(views).indexOf(Meteor.userId()) !== -1) {
                        arr = [];
                        for (_i = 0, _len = views.length; _i < _len; _i++) {
                            item = views[_i];
                            if (item.userId !== Meteor.userId()) {
                                arr.push({
                                    userId: item.userId,
                                    createdAt: item.createdAt
                                });
                            }
                        }
                        return Posts.update({
                            _id: Session.get("partnerId")
                        }, {
                            $set: {
                                views: arr
                            }
                        });
                    }
                } else {
                    return PUB.toast('您已经加入过了！');
                }
            }
        }
    });
    var cityVar = new ReactiveVar('定位中');
    var positionVar = new ReactiveVar({position: {latitude: 0, longitude: 0}});
    Template.add_partner.helpers({
        city: function(){
          return cityVar.get();
        },
        titleval: function() {
            return Session.get("titleval");
        },
        dateval: function() {
            return Session.get("dateval");
        },
        daysval: function() {
            return Session.get("daysval");
        },
        introval: function() {
            return Session.get("introval");
        },
        address: function() {
            return Session.get("userAddress");
        },
        shopName: function() {
            if (Session.get("shopName") === '' || Session.get("shopName") === void 0) {
                "";
            }
            return Session.get("shopName");
        },
        shopId: function() {
            if (Session.get("shopId") === '' || Session.get("shopId") === void 0) {
                "";
            }
            return Session.get("shopId");
        },
        files: function() {
            return Template.public_loading_index.__helpers.get('images')();
        },
        showAdmin: function(e) {
            if (e === 1 || e === 2) {
                return true;
            } else {
                return false;
            }
        }
    });
    Session.setDefault("daysval", "1");
    Session.setDefault("dateval", (new Date()).getFullYear() + '-' + ((new Date()).getMonth() + 1) + '-' + (new Date()).getDate());
    Template.add_partner.rendered = function() {
        var geoc, point, post;
        Template.public_upload_index.__helpers.get('reset')();
        
        cityVar.set('定位中');
        positionVar.set({position: {latitude: 0, longitude: 0}});
        getPosition(function(error, result){
          if(error){
            PUB.toast('定位失败～')
          }else{
            cityVar.set(result.address.city)
            positionVar.set({position: result.position});
          } 
        });
      
        if (Session.get("add_partner_type") === 'edit') {
            post = Posts.findOne(Session.get("add_partner_id"));
            Session.set("titleval", post.title);
            Session.set("dateval", post.startDate);
            Session.set("daysval", post.days);
            Session.set("introval", post.text);
            Session.set("shopId", post.shopId || '');
            Session.set("shopName", post.shopName || '');
            Session.set("public_upload_index_images", post.images || []);
        }else{
            Session.set("add_partner_id", '');
            Session.set("titleval", '');
            Session.set("dateval", (new Date()).getFullYear() + '-' + ((new Date()).getMonth() + 1) + '-' + (new Date()).getDate());
            Session.set("daysval", '1');
            Session.set("introval", '');
            Template.public_upload_index.__helpers.get('reset')();
        }
//        if (Meteor.user().profile.city) {
//            Session.set("userAddress", Meteor.user().profile.city);
//        } else {
//            Session.set("userAddress", Session.get("city"));
//        }
//        geoc = new BMap.Geocoder();
//        point = new BMap.Point(Session.get('location').longitude, Session.get('location').latitude);
//        geoc.getLocation(point, function(rs) {
//            var addComp, requestUrl;
//            if (rs && rs.addressComponents) {
//                addComp = rs.addressComponents;
//                if (addComp.city && addComp.city !== '') {
//                    Session.set("userAddress", addComp.city + ' ' + addComp.district);
//                }
//            } else {
//                requestUrl = "http://maps.googleapis.com/maps/api/geocode/json?latlng=" + Session.get('location').latitude + ',' + Session.get('location').longitude + '&sensor=false';
//                Meteor.http.call("GET", requestUrl, function(error, result) {
//                    var results;
//                    if (result.statusCode === 200) {
//                        results = result.content.results;
//                        Session.set("userAddress", JSON.stringify(result));
//                    }
//                });
//            }
//        });
    };
    Template.add_partner.events({
        "click #btn_back": function() {
            return window.page.back();
        },
        "click #addphoto": function() {
            return uploadFile(function(result) {
                var upload_images;
                $('#loading').css('display', '');
                if (result) {
                    upload_images = Session.get("upload_images");
                    upload_images.push({
                        url: result
                    });
                    Session.set("upload_images", upload_images);
                }
                return $('#loading').css('display', 'none');
            });
        },
        "click .shop": function(event) {
            console.log("return_view is add_partner");
            Session.set("return_view", "add_partner");
            Session.set("titleval", $('#title').val());
            Session.set("dateval", $('#date').val());
            Session.set("daysval", $('#days').val());
            Session.set("introval", $('#intro').val());
            Session.set("shop_seach_key", "");
            return PUB.page("shop_list");
        },
        "click #save": function(event) {
            var city, date, days, e, geometry, intro, location, registrationID, registrationType, shopId, shopName, tags, title, tokenInfo, upload_images, userPicture;
            if (Meteor.user() === null) {
                PUB.page("dashboard");
                false;
            } else {
                city = $('#admin_location').val();
                if (city === '' || city === void 0) {
                    city = cityVar.get();
                }
                if(city === '定位中')
                  city = '';
                shopName = $(".shop").attr("shopName");
                shopId = $(".shop").attr("shopId");
                title = $('#title').val();
                date = $('#date').val();
                days = $('#days').val();
                intro = $('#intro').val();
                tags = [];
                if (date === '' || intro === '') {
                    PUB.toast('请完整填写表单！');
                } else {
                    location = positionVar.get().position;
                    geometry = {
                      type: "Point",
                      coordinates: [location.longitude, location.latitude]
                    };
                    if (intro && intro !== '') {
                        Tags.find({}).forEach(function(t) {
                            if ((title + intro).indexOf(t.tag) !== -1) {
                                return tags.push({
                                    id: t._id,
                                    tag: t.tag
                                });
                            }
                        });
                        try {
                            userPicture = Meteor.user().profile.picture;
                        } catch (_error) {
                            e = _error;
                            userPicture = null;
                        }
                        registrationID = Session.get('registrationID');
                        registrationType = Session.get('registrationType');
                        tokenInfo = {
                            type: registrationType,
                            token: registrationID
                        };
                        
                        postPartner = function() {
                            var city, date, days, e, geometry, intro, location, registrationID, registrationType, shopId, shopName, tags, title, tokenInfo, upload_images, userPicture;
                            var isCustomCity = false;
                          
                            city = $('#admin_location').val();
                            if (city === '' || city === void 0) {
                              city = cityVar.get();
                            }else{
                              if(cityVar.get() !== city){
                                isCustomCity = true;
                              }
                            }
                            if(city === '定位中')
                              city = '';
                            shopName = $(".shop").attr("shopName");
                            shopId = $(".shop").attr("shopId");
                            title = $('#title').val();
                            date = $('#date').val();
                            days = $('#days').val();
                            intro = $('#intro').val();
                            tags = [];
                            location = positionVar.get().position;
                            geometry = {
                              type: "Point",
                              coordinates: [location.longitude, location.latitude]
                            };
                            if (intro && intro !== '') {
                                try {
                                    userPicture = Meteor.user().profile.picture;
                                } catch (_error) {
                                    e = _error;
                                    userPicture = null;
                                }
                            }
                            registrationID = Session.get('registrationID');
                            registrationType = Session.get('registrationType');
                            tokenInfo = {
                                type: registrationType,
                                token: registrationID
                            };
                            upload_images = Template.public_upload_index.__helpers.get('images')();
                            
                            if (Session.get("add_partner_type") === 'edit') {
                                Posts.update({
                                    _id: Session.get("add_partner_id")
                                }, {
                                    $set: {
                                        type: 'pub_board',
                                        title: title,
                                        text: intro,
                                        startDate: date,
                                        days: days,
                                        shopId: shopId,
                                        shopName: shopName,
                                        images: upload_images,
                                        userId: Meteor.userId(),
                                        city: city,
                                        isCustomCity: isCustomCity,
                                        location: geometry
                                    }
                                }, function(error, count) {
                                    var isadd, item, photo, photos, _i, _j, _len, _len1, _results;
                                    if (error || count <= 0) {
                                        return console.log("partner update err.");
                                    } else {
                                        photos = Photos.find({
                                            userId: Meteor.userId()
                                        }).fetch();
                                        _results = [];
                                        for (_i = 0, _len = upload_images.length; _i < _len; _i++) {
                                            item = upload_images[_i];
                                            isadd = true;
                                            for (_j = 0, _len1 = photos.length; _j < _len1; _j++) {
                                                photo = photos[_j];
                                                if (photo.imageUrl === item.url) {
                                                    isadd = false;
                                                    break;
                                                }
                                            }
                                            if (isadd) {
                                                _results.push(Photos.insert({
                                                    userId: Meteor.userId(),
                                                    createAt: new Date(),
                                                    postId: _id,
                                                    imageUrl: item.url
                                                }));
                                            } else {
                                                _results.push(void 0);
                                            }
                                        }
                                        Session.set("add_partner_type",'');
                                        return _results;
                                    }
                                });
                                PUB.page("pub_board");
                                Session.set("titleval", '');
                                Session.set("dateval", (new Date()).getFullYear() + '-' + ((new Date()).getMonth() + 1) + '-' + (new Date()).getDate());
                                Session.set("daysval", '1');
                                Session.set("introval", '');
                                Template.public_upload_index.__helpers.get('reset')();
                            } else {
                                Posts.insert({
                                    type: 'pub_board',
                                    title: title,
                                    text: intro,
                                    startDate: date,
                                    days: days,
                                    good: 0,
                                    views: [],
                                    toJoin: [],
                                    replys: [],
                                    reports: [],
                                    report: 0,
                                    token: tokenInfo,
                                    tags: tags,
                                    shopId: shopId,
                                    shopName: shopName,
                                    images: upload_images,
                                    userId: Meteor.userId(),
                                    name: Meteor.user().profile.nike,
                                    nike: Meteor.user().profile.nike,
                                    userPicture: userPicture,
                                    city: city,
                                    isCustomCity: isCustomCity,
                                    location: geometry,
                                    createdAt: new Date()
                                }, function(error, _id) {
                                    var item, _i, _len, _results;
                                    console.log("Posts insert _id is " + _id);
                                    _results = [];
                                    for (_i = 0, _len = upload_images.length; _i < _len; _i++) {
                                        item = upload_images[_i];
                                        _results.push(Photos.insert({
                                            userId: Meteor.userId(),
                                            createAt: new Date(),
                                            postId: _id,
                                            imageUrl: item.url
                                        }));
                                    }
                                return _results;
                                });
                            }
                            PUB.page("pub_board");
                            Session.set("add_partner_id", '');
                            Session.set("titleval", '');
                            Session.set("dateval", (new Date()).getFullYear() + '-' + ((new Date()).getMonth() + 1) + '-' + (new Date()).getDate());
                            Session.set("daysval", '1');
                            Session.set("introval", '');
                            Template.public_upload_index.__helpers.get('reset')();
                        };
                        
                        
                        upload_images = Template.public_upload_index.__helpers.get('images')();
                        
                        if (upload_images.length > 0) {
                            Template.public_upload_index.__helpers.get('uploadImages')(function(isSuc) {
                                if (isSuc == false)
                                    PUB.toast('发表失败，请重新发表搭伙。');
                                else {
                                    postPartner();
                                    Session.set('isDialogView', false);
                                }
                            });
                        }
                        else {
                            postPartner();
                            Session.set('isDialogView', false);
                        }

                        
                    }
                }
            }
            return false;
        }
    });
}
