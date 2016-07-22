if (Meteor.isClient) {
    Session.set('statics_data',{
        total_posts:0,
        total_ad_posts:0,
        total_localservice_posts:0,
        total_pubboard_posts:0,
        total_notes_posts:0,
        total_comments: 0,
        total_partner_count:0,
        total_pending_WiFi_merchant:0,
        total_WiFi_merchant:0,
        total_chat_records:0,
        total_register_generalusers:0,
        total_wechat_users:0,
        total_register_users:0,
        total_vip_users:0
    });

    Template.stat.rendered = function(){
        Meteor.call('getStatics',function(error,data){
            if (error){
                console.log('got error from call');
                return;
            }
            Session.set('statics_data',data);
            console.log("Got data " + JSON.stringify(data));
        });
    };
    Template.stat.helpers({
        total_ad_posts: function(){
            return Session.get('statics_data').total_ad_posts;
        },
        total_posts: function(){
            return Session.get('statics_data').total_posts;
        },
        total_localservice_posts: function(){
            return Session.get('statics_data').total_localservice_posts;
        },
        total_pubboard_posts: function(){
            return Session.get('statics_data').total_pubboard_posts;
        },
        total_notes_posts: function() {
            return Session.get('statics_data').total_notes_posts;
        },
        total_comments: function() {
            return Session.get('statics_data').total_comments;
        },
        total_partner_count: function(){
            return Session.get('statics_data').total_partner_count;
        },
        total_pending_WiFi_merchant: function(){
            return Session.get('statics_data').total_pending_WiFi_merchant;
        },
        total_WiFi_merchant: function(){
            return Session.get('statics_data').total_WiFi_merchant;
        },
        total_chat_records: function(){
            return Session.get('statics_data').total_chat_records;
        },
        total_register_generalusers: function(){
            return Session.get('statics_data').total_register_generalusers;
        },
        total_wechat_users: function(){
            return Session.get('statics_data').total_wechat_users;
        },
        total_register_users: function(){
            return Session.get('statics_data').total_register_users;
        },
        total_vip_users: function(){
            return Session.get('statics_data').total_vip_users;
        }
    });
    Template.stat.events({

    });
}