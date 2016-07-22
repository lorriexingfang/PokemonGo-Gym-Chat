Meteor.startup ->
  # 配置活动
  # Events.remove({})
  if Events.find({eventNo: '2015-01'}).count() <= 0
    Events.insert(
      {
        title: '发搭伙－抢客栈'
        eventNo: '2015-01'
        subhead: '即日起凡是在“小店公告”手机APP发布搭伙消息就有机会获得免费住宿大理客栈的机会。'
        describe: '<p>想去大理旅游的朋友们，您们的福利来了！为了能够让大家开心、省心游大理，“小店公告”在新的一年来临之际也为大家送出了特别的心意！</p><p>特别注明：每人限住一晚（价值120元标间），名额有限，获得免费住宿的人员名单将在“小店公告”最新活动板块以及微信公众平台公布，敬请关注订阅号“dahuo51”了解详情。</p>'
        startDate: new Date('2015-02-27 00:00:00')
        # endDate: new Date('2015-03-31 23:59:59')
        eachType: 'day'
        maxQuota: 0
        eachQuota: 4
        eachFilter: []
        isSendSms: true
        isSendMsg: true

        range: [{
          start: '10:00:00'
          end: '09:59:59'
        }]

        message: {
          successMsg: '恭喜你抢到了免费客栈，稍候会为您发送短消息，请注意查收哦！'
          failMsg: '亲，您来迟了，名额已经被抢完了，明早10点记得早点儿来哦！'
          successSms: '尊敬的用户，恭喜您抢到了“大理悦来客栈”的免费入住资格，地址：大理古城文献路81号(近古城南门口)，凭验证码#{ticketCode}提前一周预约换取入住房间，预约电话：0872-2681335，此验证码有效期15天。详询0871-65134197。'
          failSms: '尊敬的用户，很遗憾您没有抢到今天的免费客栈，明早10点记得早点儿来哦，期待您好运！'
        }
      }
    )

  # 处理报名用户
  mongoPosts.after.insert (userId, doc)->
    if doc.type is 'pub_board'
      event = Events.findOne({eventNo: '2015-01'})
      now = new Date()

      if event.startDate > now or (event.endDate isnt undefined and now > event.endDate)
        return
      
      if doc.events isnt undefined and doc.events isnt []
        for item in doc.events
          if item.eventNo is event.eventNo
            Meteor.call 'enterEvent', event.eventNo
            break
        
#      if doc.text.indexOf("#免费客栈#") >= 0
#        Meteor.call 'enterEvent', event.eventNo
      