#服务器端公共方法
Meteor.methods 
    #查询posts
    Posts:(selector,options)->
        if options
            if options["limit"] is undefined
                options.limit = 100
            Posts.find(selector,options).fetch()
        else
            Posts.find(selector, {limit: 100}).fetch()