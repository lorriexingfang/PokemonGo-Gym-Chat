$(window).scroll ->
  scrollTop = $(this).scrollTop()
  scrollHeight = $(document).height()
  windowHeight = $(this).height()

  if Session.equals('view', 'my_blackboard') and Session.get('my_blackboard_loaded_count') == Session.get('my_blackboard_limit') and scrollTop > 0 and scrollTop >= scrollHeight-windowHeight
    limit = Session.get('my_blackboard_limit') + 10
    Session.set('my_blackboard_limit', limit)
    Session.set('my_blackboard_loading', true)
    $('.my-blackboard-loading').html('加载中，请稍候...')
        
    $.when(
      customSubscribe('wifiMyBlackboards', Meteor.userId(), limit, (type, reason) ->
        if type is 'ready'
          Session.set('wifiFavorite_loading', false)
          console.log("customSubscribe wifiMyBlackboards ready.")
      )
    ).done(() ->
      $('.my-blackboard-loading').html('上拉加载更多...')
      Session.set('my_blackboard_loading', false)
      return console.log("customSubscribe wifiMyBlackboards done.");
    ).fail(() ->
      $('.my-blackboard-loading').html('上拉加载更多...')
      Session.set('my_blackboard_loading', false)
      return console.log("customSubscribe wifiMyBlackboards failed.");
    )


Template.my_blackboard.events
    "click #back_btn":->
        window.page.back()

Session.setDefault('my_blackboard_limit', 10)

Template.my_blackboard_main.helpers
  blackboards: () ->
    limit = Session.get('my_blackboard_limit')
    console.log('limit', limit)
    wifis = Wifis.find({'createdBy':Meteor.userId()}, {sort: {createdAt: -1},limit:limit})

    Session.set('my_blackboard_loaded_count', wifis.count())
    console.log('my_blackboard_loaded_count', Session.get('my_blackboard_loaded_count'))
    wifis
  has_more_data: () ->
    if Session.get('my_blackboard_loaded_count') is undefined or Session.get('my_blackboard_loaded_count') <= 0
      return false
    else if Session.get('my_blackboard_loading')
      return true
    else
      if Session.get('my_blackboard_loaded_count') is Session.get('my_blackboard_limit')
        return true
      else
        return false    
Template.my_blackboard_list.helpers
    trunc_str: (len, pass) ->
        if pass.length > len
            pass = pass.substring(0, len) + '...'
        return pass
    isFavorite: (id) ->
        return WifiFavorite.findOne({userId: Meteor.userId(), wifiID: this._id}) != undefined
    time: (val) ->
        now = new Date()
        return GetTime0(now - val)
    getWifiPicture: (latestPicture) ->
        if latestPicture == undefined
            return 'http://data.youzhadahuo.com/fZ8PtzM4rmYJKpCaz_1447184412955_cdv_photo_001.jpg'
        else
            return latestPicture
    get_distance: (val) ->
        location = Session.get('location')
        if val isnt undefined and val.location isnt undefined and location isnt undefined
            return distance(location.longitude, location.latitude, val.location.coordinates[0], val.location.coordinates[1])
        else
            return ''
    gec: (id, obj)->
        if obj? and obj.address? and obj.address isnt ''
          return obj.address.replace('"', '').replace('"', '')
        else
          if obj? and obj.coordinates? and obj.coordinates[0] isnt 0 and obj.coordinates[1] isnt 0
            geoc = new BMap.Geocoder();
            point = new BMap.Point(obj.coordinates[0],obj.coordinates[1]);
            geoc.getLocation(point, (rs)->
              if rs and rs.addressComponents
                addComp = rs.addressComponents;
                if addComp.city and addComp.city isnt ''
                  console.log(addComp.province + ", " + addComp.city + ", " + addComp.district + ", " + addComp.street + ", " + addComp.streetNumber);
                  #Session.set("wifiBoardLocation", addComp.province + addComp.city + addComp.district + addComp.street);
                  obj.address = addComp.province + addComp.city + addComp.district + addComp.street
                  Wifis.update(
                      {_id: id}
                      {$set: {'location': obj}}
                      (err, number)->
                        if (err)
                          console.log('update location ' + err);
                  )
                else
                  requestUrl = "http://maps.googleapis.com/maps/api/geocode/json?latlng="+obj.coordinates[1]+','+obj.coordinates[0]+'&sensor=false'
                  Meteor.http.call "GET",requestUrl,(error,result)->
                    if result.statusCode is 200
                      results = result.data.results
                      if results.length > 1
                        Session.set("wifiBoardLocation",JSON.stringify(results[1].formatted_address))
                        console.log("gooleappis" + JSON.stringify(results[1].formatted_address))
                        obj.address = Session.get("wifiBoardLocation")
                        Wifis.update(
                            {_id: id}
                            {$set: {'location': obj}}
                            (err, number)->
                              if err
                                console.log('update location ' + err);
                        )
            )
          return '定位中...';
Template.my_blackboard_list.events
    'click .btn-tuya': (e) ->
        e.stopPropagation();
        if Meteor.userId() is null
          PUB.toast('请登录后操作！')
          return

        Template.wifiPubWifi.__helpers.get('open')(this._id, true)
        clearSysMessageBadge(this._id)
    'click .btn-cancel-favorite': (e) ->
        e.stopPropagation();
        if Meteor.userId()
            favorite = WifiFavorite.findOne({userId: Meteor.userId(), wifiID: this._id})
            if favorite is undefined
                window.PUB.toast('您还没有收藏此小店呢！')
            else
                WifiFavorite.remove(favorite._id, (err) ->
                    if(err)
                        window.PUB.toast('操作失败，请重试！')
                )
    'click .btn-add-favorite': (e) ->
        e.stopPropagation();
        if Meteor.userId()
            wifis = Wifis.findOne({'_id': this._id})
            wifiUser = {}

            for key of wifis
                if key is '_id'
                    wifiUser.wifiID = wifis._id
                else
                    wifiUser[key] = wifis[key]
            
            wifiUser.userId = Meteor.userId()
            wifiUser.accessAt = new Date()
            WifiFavorite.insert(wifiUser, (err) ->
                if err and err.error isnt 403
                    console.log(err);
                    window.PUB.toast('收藏失败！')
            )
        else
          window.PUB.toast('请登录后操作！')
    'click li.my-blackboard-list-li': (e) ->
        e.stopPropagation()
        Template.wifiPubWifi.__helpers.get('open')(this._id)
        clearSysMessageBadge(this._id)

