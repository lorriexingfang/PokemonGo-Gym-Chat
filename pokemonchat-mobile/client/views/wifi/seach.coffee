resultVar = new ReactiveVar([])

$(window).scroll ()->
    scrollTop = $(this).scrollTop()
    scrollHeight = $(document).height()
    windowHeight = $(this).height()
    #console.log("Frank: view="+Session.get('view')+", scrollTop="+scrollTop+", scrollHeight="+scrollHeight+", windowHeight="+windowHeight+", "+Session.get('wifi_seach_users_count')+", "+Session.get('wifi_seach_limit'))
    if ((Session.equals('view', 'wifiSeach')) and (Session.get('wifi_seach_users_count') is Session.get('wifi_seach_limit')) and ((scrollTop > 0) and (scrollTop >= scrollHeight-windowHeight)))
        limit = Session.get('wifi_seach_limit') + 10;
        Session.set('wifi_seach_limit', limit);
        $('#load-more-wifi_search').html('加载中，请稍候...')
        #showLoading()
        $.when(
            text = $('#searchBox').val().trim()
            Session.set('wifi_seach_loading', true)
            customSubscribe('wifiMerchantSearch', text, {limit:limit}, (type, reason)->
              if type is 'ready'
                Session.set('wifi_seach_loading', false)
            )
        ).done(()->
            #console.log("customSubscribe wifiMerchantSearch done.");
            #return closeLoading()
        ).fail(()->
            #console.log("customSubscribe wifiMerchantSearch failed.");
            #return closeLoading()
        )

Template.wifiSeach.created =->
  #Session.set('wifi_seach_limit', 0);
Template.wifiSeach.onRendered ()->
  this.$('.wifi-seach').css('min-height', $('body').height() - 48)
  this.$('.seach input').css('width', $('.seach').width() - 40)
  #this.$('.wifiOffline .list').css('padding-bottom', 0)
  $('#searchBox').val(Session.get('last_search_key'))
  limit = Session.get('wifi_seach_limit')
  if limit is 0
    $('#searchBox').focus()
Template.wifiSeach.helpers
  city: ()->
    if Session.get('city') is undefined then '城市' else Session.get('city')
  users: ()->
    resultVar.get()
  key: ()->
    Session.get('last_search_key')
  loading: ()->
    false
  no_data: (val)->
    false
  count: (users)->
    count = 0
    if users?
      for item in users
        if(item.status is 'online')
          count += 1
    count
  isSearching: ()->
    true
  has_more_data: ()->
    if Session.get('wifi_seach_loading')
        true
    else if Session.get('wifi_seach_users_count') is Session.get('wifi_seach_limit')
        true
    else
        false
  getBusinessUsers: ()->
    limit = Session.get('wifi_seach_limit')
    if limit is 0
      return []
    buildRegExp = (searchText)->
        parts = searchText.trim().split(/[ \-\:]+/);
        return new RegExp("(" + parts.join('|') + ")", "ig");
    text = Session.get('last_search_key')
    regExp = buildRegExp(text)
    selector = {$or: [
        {'profile.business': regExp},
        {'profile.address': regExp},
        {'profile.tel': regExp}
        ]};
    users = Meteor.users.find(selector, {sort: {'business.readCount': -1}, limit: limit})
    #console.log("users count="+users.count()+", "+Meteor.users.find(selector, {sort: {'business.readCount': -1}}).count());
    if Session.get('wifi_seach_users_count') isnt users.count()
      Session.set('wifi_seach_users_count', users.count())
    users

Template.wifiSeach.events
  'click .leftButton': ()->
    if Session.equals('wifi-business-seaching', true)
      delete Session.keys['wifi-business-seaching']
    #$('.wifiOffline .list').css('padding-bottom', 55)
    Session.set('view', Session.get('wifi-seach-return-view'))
  'click #wifi-seach-city-select': ()->
    Session.set('city-return-view', Session.get('view'))
    Session.set('view', 'city')
  'keyup input': _.throttle((e)->
      text = $(e.target).val().trim()
      Session.set('last_search_key', text)
      Session.set('wifi_seach_limit', 0)
      Session.set('wifi_seach_limit', 10)
      Session.set('wifi_seach_loading', true)
      customSubscribe('wifiMerchantSearch', text, {limit:10}, (type, reason)->
        if type is 'ready'
          Session.set('wifi_seach_loading', false)
      )
    ,200)
  'click #searchForBox': _.throttle(()->
      text = $('#searchBox').val().trim()
      Session.set('last_search_key', text)
      Session.set('wifi_seach_limit', 0)
      Session.set('wifi_seach_limit', 10)
      Session.set('wifi_seach_loading', true)
      customSubscribe('wifiMerchantSearch', text, {limit:10}, (type, reason)->
        if type is 'ready'
          Session.set('wifi_seach_loading', false)
      )
    ,200)
  'click .list li': (e)->
    Meteor.call('viewWifiBusiness', e.currentTarget.id)
    Session.set('online-view', 'wifiOnlineText')
    Session.set('online-return', Session.get('view'))
    Session.set('wifi-business-seaching', true)
    Session.set('wifiOnlineId', e.currentTarget.id)
    text = $('#searchBox').val().trim()
    PUB.page("wifiOnline")







###
seachKey = new ReactiveVar('')
resultVar = new ReactiveVar([])
loadVar = new ReactiveVar(false)
wifi_search_scrolltop = 0

$(window).scroll ()->
    scrollTop = $(this).scrollTop()
    scrollHeight = $(document).height()
    windowHeight = $(this).height()
    #console.log("Frank: view="+Session.get('view')+", scrollTop="+scrollTop+", scrollHeight="+scrollHeight+", windowHeight="+windowHeight+", "+Session.get('wifi_seach_users_count')+", "+Session.get('wifi_seach_limit'))
    if ((Session.equals('view', 'wifiSeach')) and (Session.get('wifi_seach_users_count') is Session.get('wifi_seach_limit')) and ((scrollTop > 0) and (scrollTop >= scrollHeight-windowHeight)))
        limit = Session.get('wifi_seach_limit') + 20;
        Session.set('wifi_seach_limit', limit);
        $('#load-more-wifi_search').html('加载中，请稍候...')
        #showLoading()
        $.when(
            text = $('#searchBox').val().trim()
            WifiBusinessSearch.search(text, {limit:limit})
        ).done(()->
            #Meteor.setTimeout(
            #    ()->
            #        return closeLoading()
            #    5000
            #)
        ).fail(()->
            return $('#load-more-wifi_search').html('上拉加载更多...')
            #return closeLoading()
        )

Template.wifiSeach.created =->
  #Session.set('wifi_seach_limit', 0);
Template.wifiSeach.onRendered ()->
  #seachKey.set('')
  #resultVar.set([])
  loadVar.set(false)
  limit = Session.get('wifi_seach_limit')
  if limit is 0
    $('#searchBox').focus()
  Session.set('isSearching', false)
  this.$('.wifi-seach').css('min-height', $('body').height() - 48)
  this.$('.seach input').css('width', $('.seach').width() - 40)
  #this.$('.wifiOffline .list').css('padding-bottom', 0)
  console.log("wifiSeach.onRendered");
  $('#searchBox').val(Session.get('last_search_key'))
  #if Session.get('last_search_key')
  #  WifiBusinessSearch.search(Session.get('last_search_key'), {limit:40})
  #  console.log("wifiSeach.onRendered: last_search_key = "+Session.get('last_search_key'));
Template.wifiSeach.helpers
  city: ()->
    return if Session.get('city') is undefined then '城市' else Session.get('city')
  users: ()->
    return resultVar.get()
  key: ()->
    return seachKey.get()
  loading: ()->
    return loadVar.get() is true
  no_data: (val)->
    if(seachKey.get() is '')
      return false

    return val.length <= 0
  count: (users)->
    count = 0
    if users?
      for item in users
        if(item.status is 'online')
          count += 1
    return count
  isSearching: ()->
    true
    #console.log("isSearching...");
    #if Session.get('isSearching') is false
    #  false
    #else
    #  true

    #return WifiBusinessSearch.getStatus().loading;
  has_more_data: ()->
    #console.log("wifi_seach_users_count="+Session.get('wifi_seach_users_count')+", wifi_seach_limit="+Session.get('wifi_seach_limit')+", "+WifiBusinessSearch.getStatus().loading)
    if Session.get('wifi_seach_users_count') is undefined or Session.get('wifi_seach_users_count') <= 0
       false
    else if WifiBusinessSearch.getStatus().loading is true
        true
    else
        if Session.get('wifi_seach_users_count') is Session.get('wifi_seach_limit')
            true
        else
            false

  getBusinessUsers: ()->
    limit = Session.get('wifi_seach_limit')
    if limit is 0
        return [];
    users = WifiBusinessSearch.getData({
                transform: (matchText, regExp)->
                  #return matchText.replace(regExp, "<b>$&</b>")
                  return matchText
                , sort: {createdAt: -1}}, true)
    console.log("getBusinessUsers: users count = "+users.count());
    #if users?
    #    console.log("  users="+JSON.stringify(users));
    if Session.get('wifi_seach_users_count') isnt users.count()
      Session.set('wifi_seach_users_count', users.count())
      #closeLoading()
    users

Template.wifiSeach.events
  'click .leftButton': ()->
    #$('.wifiOffline .list').css('padding-bottom', 55)
    Session.set('view', Session.get('wifi-seach-return-view'))
  'click #wifi-seach-city-select': ()->
    Session.set('city-return-view', Session.get('view'))
    Session.set('view', 'city')
  'keyup input': _.throttle((e)->
      text = $(e.target).val().trim()
      Session.set('wifi_seach_limit', 20);
      WifiBusinessSearch.search(text, {limit:20})
      if text.length > 0 then Session.set('isSearching', true) else Session.set('isSearching', false)

    ,200)

    
    #seachKey.set(e.currentTarget.value)
    #resultVar.set([])
    
    #if(e.currentTarget.value isnt '')
    #  loadVar.set(true)
    #  Meteor.call(
    #    'getWifiBusinessByKey'
    #    e.currentTarget.value
    #    (err, result)->
    #      if(err)
    #        resultVar.set([])
    #        loadVar.set(false)
    #      else
    #        resultVar.set(result)
    #        loadVar.set(false)
    #  )

  'click .list li': (e)->
    Meteor.call('viewWifiBusiness', e.currentTarget.id)
    Session.set('online-view', 'wifiOnlineText')
    Session.set('wifiOnlineId', e.currentTarget.id)
    #Session.set('view', 'wifiOnline')
    text = $('#searchBox').val().trim()
    Session.set('last_search_key', text)
    PUB.page("wifiOnline")
    #loadData('view', 'wifiOnline')
    #wifi_search_scrolltop = document.body.scrollTop
    #Template.wifiOnline.__helpers.get('show')()
###