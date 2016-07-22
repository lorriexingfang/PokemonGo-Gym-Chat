Meteor.startup ->
    if Tags.find().count() < 1
        Tags.insert {"parent":"热门目的地","tag":"迪庆","title":"迪庆","img":"/home/113.jpg","bg":"/home/113.jpg","order":6}
        Tags.insert {"parent":"热门目的地","tag":"红河","title":"红河","img":"/home/114.jpg","bg":"/home/114.jpg","order":7}
        Tags.insert {"parent":"热门目的地","tag":"怒江","title":"怒江","img":"/home/115.jpg","bg":"/home/115.jpg","order":8}
        Tags.insert {"parent":"热门目的地","tag":"曲靖","title":"曲靖","img":"/home/116.jpg","bg":"/home/116.jpg","order":9}
        Tags.insert {"parent":"热门目的地","tag":"思茅","title":"思茅","img":"/home/117.jpg","bg":"/home/117.jpg","order":9}
        Tags.insert {"parent":"热门目的地","tag":"文山","title":"文山","img":"/home/118.jpg","bg":"/home/118.jpg","order":9}
        Tags.insert {"parent":"热门目的地","tag":"西双版纳","title":"西双版纳","img":"/home/119.jpg","bg":"/home/119.jpg","order":9}
        Tags.insert {"parent":"热门目的地","tag":"昭通","title":"昭通","img":"/home/120.jpg","bg":"/home/120.jpg","order":9}
        Tags.insert {"parent":"热门目的地","tag":"楚雄","title":"楚雄","img":"/home/111.jpg","bg":"/home/111.jpg","order":4}
        Tags.insert {"parent":"热门目的地","tag":"德宏","title":"德宏","img":"/home/112.jpg","bg":"/home/112.jpg","order":5}
        Tags.insert {"parent":"国内","tag":"西藏","title":"西藏","img":"/home/0.jpg","bg":"/home/top.1.jpg","order":0}
        Tags.insert {"parent":"国内","tag":"云南","title":"云南","img":"/home/1.jpg","bg":"/home/top.2.jpg","order":1}
        Tags.insert {"parent":"国内","tag":"四川","title":"四川","img":"/home/2.jpg","bg":"/home/top.3.jpg","order":2}
        Tags.insert {"parent":"国内","tag":"青海","title":"青海","img":"/home/3.jpg","bg":"/home/top.4.jpg","order":3}
        Tags.insert {"parent":"国内","tag":"新疆","title":"新疆","img":"/home/4.jpg","bg":"/home/top.5.jpg","order":4}
        Tags.insert {"parent":"国内","tag":"陕西","title":"陕西","img":"/home/5.jpg","bg":"/home/top.1.jpg","order":5}
        Tags.insert {"parent":"国内","tag":"贵州","title":"贵州","img":"/home/6.jpg","bg":"/home/top.2.jpg","order":6}
        Tags.insert {"parent":"国内","tag":"海南","title":"海南","img":"/home/7.jpg","bg":"/home/top.3.jpg","order":7}
        Tags.insert {"parent":"国内","tag":"湖南","title":"湖南","img":"/home/8.jpg","bg":"/home/top.4.jpg","order":8}
        Tags.insert {"parent":"国内","tag":"广西","title":"广西","img":"/home/9.jpg","bg":"/home/top.5.jpg","order":9}
        Tags.insert {"parent":"海外","tag":"马尔代夫","title":"马尔代夫","img":"/home/0.jpg","bg":"/home/top.1.jpg","order":0}
        Tags.insert {"parent":"海外","tag":"巴厘岛","title":"巴厘岛","img":"/home/1.jpg","bg":"/home/top.2.jpg","order":1}
        Tags.insert {"parent":"海外","tag":"普吉岛","title":"普吉岛","img":"/home/2.jpg","bg":"/home/top.3.jpg","order":2}
        Tags.insert {"parent":"海外","tag":"济州岛","title":"济州岛","img":"/home/3.jpg","bg":"/home/top.4.jpg","order":3}
        Tags.insert {"parent":"海外","tag":"皮皮岛","title":"皮皮岛","img":"/home/4.jpg","bg":"/home/top.5.jpg","order":4}
        Tags.insert {"parent":"海外","tag":"袋鼠岛","title":"袋鼠岛","img":"/home/5.jpg","bg":"/home/top.1.jpg","order":5}
        Tags.insert {"parent":"海外","tag":"长滩岛","title":"长滩岛","img":"/home/6.jpg","bg":"/home/top.2.jpg","order":6}
        Tags.insert {"parent":"海外","tag":"沙巴","title":"沙巴","img":"/home/7.jpg","bg":"/home/top.3.jpg","order":7}
        Tags.insert {"parent":"海外","tag":"棕榈岛","title":"棕榈岛","img":"/home/8.jpg","bg":"/home/top.4.jpg","order":8}
        Tags.insert {"parent":"海外","tag":"威尼斯","title":"威尼斯","img":"/home/9.jpg","bg":"/home/top.5.jpg","order":9}
        Tags.insert {"parent":"最新活动","tag":"优惠","title":"大理白族聚贤山庄特惠","img":"/blackboard/img_01.png","detail":"/partner/activity.png","order":1}
        Tags.insert {"parent":"最新活动","tag":"广告","title":"一起来吧！轿子山野营","img":"/blackboard/img_02.png","detail":"/partner/activity.png","order":2}
        Tags.insert {"parent":"最新活动","tag":"优惠","title":"大理三塔半价游","img":"/blackboard/img_03.png","detail":"/partner/activity.png","order":3}
        Tags.insert {"parent":"精选主题","tag":"户外","title":"户外旅行","img":"/partner/theme.1.jpg","bg":"/partner/theme.1.jpg","adtitle":"罗平、菌子山、多依河、九龙瀑布","ad":"户外摄影采风2日游","content":"content9","order":1}
        Tags.insert {"parent":"精选主题","tag":"露营","title":"露营旅行","img":"/partner/theme.2.jpg","bg":"/partner/theme.2.jpg","adtitle":"海峰湿地露营2日","ad":"户外休闲，拓展游戏","content":"content2","order":2}
        Tags.insert {"parent":"精选主题","tag":"摄影","title":"摄影旅行","img":"/partner/theme.3.jpg","bg":"/partner/theme.3.jpg","adtitle":"魅力云南摄影之旅","ad":"落地自驾9日游","content":"content3","order":3}
        Tags.insert {"parent":"精选主题","tag":"徒步","title":"徒步旅行","img":"/partner/theme.4.jpg","bg":"/partner/theme.4.jpg","adtitle":"野花沟两日重装徒步体验","ad":"户外徒步运动，享受野营乐趣！","content":"content11","order":4}
        Tags.insert {"parent":"精选主题","tag":"自驾","title":"自驾旅行","img":"/partner/theme.5.jpg","bg":"/partner/theme.5.jpg","adtitle":"2015新年老挝柬埔寨泰国环线自驾之旅","ad":"邂逅《泰囧》的奇妙旅程","content":"content1","order":5}
        Tags.insert {"parent":"精选主题","tag":"租车","title":"租车旅行","img":"/partner/theme.6.jpg","bg":"/partner/theme.6.jpg","adtitle":"圣诞、新年跨年狂欢","ad":"9天宝岛环岛自驾游","content":"content6","order":6}
        Tags.insert {"parent":"组团主题","tag":"高端","title":"高端团","img":"/partner/9.jpg","bg":"/partner/9.jpg","order":1}
        Tags.insert {"parent":"组团主题","tag":"精品","title":"精品团","img":"/partner/8.jpg","bg":"/partner/8.jpg","order":2}
        Tags.insert {"parent":"组团主题","tag":"美食","title":"美食团","img":"/partner/7.jpg","bg":"/partner/7.jpg","order":3}
        Tags.insert {"parent":"省内","tag":"昆明","title":"昆明","img":"/home/11.jpg","bg":"/home/11.jpg","order":0}
        Tags.insert {"parent":"省内","tag":"大理","title":"大理","img":"/home/12.jpg","bg":"/home/12.jpg","order":1}
        Tags.insert {"parent":"省内","tag":"丽江","title":"丽江","img":"/home/13.jpg","bg":"/home/13.jpg","order":2}
        Tags.insert {"parent":"省内","tag":"香格里拉","title":"香格里拉","img":"/home/14.jpg","bg":"/home/14.jpg","order":3}
        Tags.insert {"parent":"省内","tag":"拉萨","title":"拉萨","img":"/home/lasha.jpg","bg":"/home/lasha.jpg","order":4}
        Tags.insert {"parent":"省内","tag":"林芝","title":"林芝","img":"/home/linzhi.jpg","bg":"/home/linzhi.jpg","order":5}
        Tags.insert {"parent":"省内","tag":"日喀则","title":"日喀则","img":"/home/rikeze.jpg","bg":"/home/rikeze.jpg","order":6}
        Tags.insert {"parent":"省内","tag":"乌鲁木齐","title":"乌鲁木齐","img":"/home/wulumuqi.jpg","bg":"/home/wulumuqi.jpg","order":7}
        Tags.insert {"parent":"省内","tag":"喀纳斯","title":"喀纳斯","img":"/home/kenasi.jpg","bg":"/home/kenasi.jpg","order":8}
        Tags.insert {"parent":"省内","tag":"天池","title":"天池","img":"/home/tianchi.jpg","bg":"/home/tianchi.jpg","order":9}
        Tags.insert {"parent":"省内","tag":"桂林","title":"桂林","img":"/home/guilin.jpg","bg":"/home/guilin.jpg","order":10}
        Tags.insert {"parent":"省内","tag":"北海","title":"北海","img":"/home/beihai.jpg","bg":"/home/beihai.jpg","order":11}
        Tags.insert {"parent":"省内","tag":"南宁","title":"南宁","img":"/home/nanning.jpg","bg":"/home/nanning.jpg","order":12}
        Tags.insert {"parent":"热门景点","tag":"虎跳峡","title":"虎跳峡","img":"/home/130.jpg","bg":"/home/130.jpg","order":4}
        Tags.insert {"parent":"热门景点","tag":"玉龙雪山","title":"玉龙雪山","img":"/home/131.jpg","bg":"/home/131.jpg","order":4}
        Tags.insert {"parent":"热门景点","tag":"梅里雪山","title":"梅里雪山","img":"/home/132.jpg","bg":"/home/132.jpg","order":4}
        Tags.insert {"parent":"热门景点","tag":"泸沽湖","title":"泸沽湖","img":"/home/133.jpg","bg":"/home/133.jpg","order":4}
        Tags.insert {"parent":"热门景点","tag":"丽江古城","title":"丽江古城","img":"/home/134.jpg","bg":"/home/134.jpg","order":4}
        Tags.insert {"parent":"热门景点","tag":"石林","title":"石林","img":"/home/135.jpg","bg":"/home/135.jpg","order":4}

    #Save all the photos to a new mongo collection
    wifis = Wifis.find({}).fetch()
    if wifis.length > 0
      for n in [0..wifis.length-1]
        curWifiPosts = WifiPosts.find({'wifiID': wifis[n]._id}, {sort: {createTime: 1}}).fetch()
        sum = 0
        if curWifiPosts.length > 0
          for i in [0..curWifiPosts.length-1]
            if curWifiPosts[i].images and curWifiPosts[i].images.length > 0
              wifiPhotos = WifiPhotos.find({'wifiID': wifis[n]._id, 'wifiPostId': curWifiPosts[i]._id}).fetch()
              if curWifiPosts[i].images.length != wifiPhotos.length
                WifiPhotos.remove({'wifiID': wifis[n]._id, 'wifiPostId': curWifiPosts[i]._id})
                sum += curWifiPosts[i].images.length
                for j in [0..curWifiPosts[i].images.length-1]
                  createTime = curWifiPosts[i].createTime
                  myTime = new Date((createTime.getTime() + 0))
                  WifiPhotos.insert({'wifiID': wifis[n]._id, 'wifiPostId': curWifiPosts[i]._id, 'index': j, url: curWifiPosts[i].images[j].url, createTime: myTime})
              else
                sum = wifis[n].photosCnt || 0
        Wifis.update({_id:wifis[n]._id}, {$set:{photosCnt: sum}})


    #Remove invalid graffiti users
    wifis = Wifis.find({}).fetch()
    if wifis.length > 0
      for n in [0..wifis.length-1]
        wifiUsers = WifiUsers.find({'wifiID': wifis[n]._id}, {sort: {createTime: -1}}).fetch()
        uniqueWifiUsers = []
        duplicateWifiUsers = []
        if wifiUsers.length > 0
            for i in [0..wifiUsers.length-1]
                found = 0
                #console.log("uniqueWifiUsers.length="+uniqueWifiUsers.length);
                if uniqueWifiUsers.length > 0
                    for j in [0..uniqueWifiUsers.length-1]
                        #console.log("wifiUsers[i]="+JSON.stringify(wifiUsers[i])+", uniqueWifiUsers[j]"+JSON.stringify(uniqueWifiUsers[j]))
                        if wifiUsers[i].userId is uniqueWifiUsers[j].userId
                            found = 1
                            break
                if found is 0
                    uniqueWifiUsers.push(wifiUsers[i])
                else
                    duplicateWifiUsers.push(wifiUsers[i])
            #Remove all the duplicate wifi users
            if duplicateWifiUsers.length > 0
                for i in [0..duplicateWifiUsers.length-1]
                    WifiUsers.remove({_id: duplicateWifiUsers[i]._id})
            #console.log("Total="+wifiUsers.length+", unique="+uniqueWifiUsers.length+", duplicate="+duplicateWifiUsers.length)
            #console.log("  Remove "+duplicateWifiUsers.length+" users for wifiID("+wifis[n]._id+")!")

    #update all the latestPicture into the wifis collections
    ###
    console.log('Will update all the latestPicture into the wifis collections')
    wifis = Wifis.find({}).fetch()
    for n in [0..wifis.length-1]
        url = ''
        hotspots = WifiPosts.find({'wifiID': wifis[n]._id}, {sort: {createTime: -1}}).fetch()
        if hotspots.length > 0
            for i in [0..hotspots.length-1]
                images = hotspots[i].images;
                if images and images.length > 0 and images[0].url
                    url = images[0].url
                    break
        if url isnt ''
            Wifis.update({'_id': wifis[n]._id}, {$set:{'latestPicture': url}})

    `var replaceLocation = function(){
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
    }`

    replaceLocation()
    ###
    #update all back users' icons into the  WifiUsers collections
    #console.log 'Xing: update all back users icons into the  WifiUsers collections'
    #wifiusers = WifiUsers.find({}).fetch()
    #for n in [0..wifiusers.length-1]
    #    userid = wifiusers[n]._id
    #    if wifiusers[n].visitTimes isnt undefined
    #      console.log "Xing: doing nothing "
    #    else
    #      console.log "Xing: empty, set it up"
    #      WifiUsers.update({'_id': userid}, {$set: {visitTimes: 2}})
    ###