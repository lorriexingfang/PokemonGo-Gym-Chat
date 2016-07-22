if Meteor.isClient
  Template.home.helpers
    event_2015_01:->
      Template.event_2015_01_index.__helpers.get('is_valid')()
    gettMonth: ->
      month = (new Date().getMonth()) + 1
      switch month
        when 1 then '一月'
        when 2 then '二月'
        when 3 then '三月'
        when 4 then '四月'
        when 5 then '五月'
        when 6 then '六月'
        when 7 then '七月'
        when 8 then '八月'
        when 9 then '九月'
        when 10 then '十月'
        when 11 then '十一月'
        when 12 then '十二月'
        else '最新'
  Template.home.events 
    'click .top-bg': ->
      if Template.event_2015_01_index.__helpers.get('is_valid')()
        Session.set "view", "event_2015_01_index"
    'click .layout li': (e)->
      Session.set 'themeId',e.currentTarget.id
      Session.set 'tag',e.currentTarget.getAttribute('tag')
      Session.set "partner_theme_return_view", Session.get("view")
      Session.set "view", "partner_theme"
      Meteor.setTimeout(
        ()->
          document.body.scrollTop = 0
          document.documentElement.scrollTop = 0
        200
      )
    'click #nearby':->
      Session.set 'pview','partner_about'
      Session.set 'partner_finding_return_view', Session.get("view")
      Session.set 'view', 'partner_finding'

  Template.home.rendered=->
    # 在home页的时候，就预取搭伙数据
    Session.set 'data_partner_themels',Tags.find({parent:'精选主题'},{limit:6}).fetch()
    Session.set 'data_partner_groups',Tags.find({parent:'组团主题'},{limit:3}).fetch()
    #Session.set 'data_partner_find3',Posts.find({type: 'pub_board'}, {sort: {createdAt: -1},limit:3}).fetch()
    Meteor.call 'Posts',{type: "pub_board"}, {sort: {createdAt: -1},limit:3},(error, result)->
      if !error
        Session.set 'data_partner_find3',result