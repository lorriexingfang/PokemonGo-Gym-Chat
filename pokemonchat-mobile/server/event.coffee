# 活动相关的所有服务端事件/方法
Meteor.startup ->
  Meteor.methods({
    # 参加(报名)活动，@retrun:true/false
    enterEvent: (eventNo)->
      slef = this
      
      createRandomNumber = (length)->
        chars = ['0','1','2','3','4','5','6','7','8','9']
        result = ''
        
        for i in [0..length-1]
          result += chars[Math.floor(Math.random()*10)]
          
        result
      
      createTicketCode = ()->
        event = Events.findOne({eventNo: eventNo})
        if event.users isnt undefined and event.users isnt []
          for i in [0..99]
            code = createRandomNumber(6)
            exist = false
            
            for item in event.users
              if item.ticketCode is code
                exist = true
                break
            
            if !exist
              break
              
          code
        else
          createRandomNumber(6)
        
      pushUserToEvent = (status)->
        event = Events.findOne({eventNo: eventNo})
        user = Meteor.users.findOne(slef.userId)
        if user.profile is undefined
          user.profile = {}
        ticketCode = createTicketCode()
        
        if user.profile.mobile is undefined
          return
        
        Events.update(
          {_id: event._id}
          $push: {
            users: {
              id: slef.userId
              nike: if user.profile.nike isnt undefined then user.profile.nike else user.username
              headimg: user.profile.picture
              enterDate: new Date()
              status: status
              isSendSms: event.isSendSms
              isSnedMsg: event.isSendMsg
              update: new Date()
              ticketCode: if status is 'success' then ticketCode else ''
            }
          }
          {}
          (err, result)->
            if err
              throw err
            else
              # 发送消息
              if event.isSendMsg
                user_helper = Meteor.users.findOne({'username': TRAVELLER_HELPER})
                mongoChats.insert(
                  {
                    userId: user_helper._id
                    userName: user_helper.profile.nike
                    userPicture: user_helper.profile.picture
                    toUserId: slef.userId
                    toUserName: if user.profile.nike isnt undefined then user.profile.nike else user.username
                    toUserPicture: user.profile.picture
                    text: if status is 'success' then event.message.successMsg.replace('#{ticketCode}', ticketCode) else event.message.failMsg
                    isRead: false
                    readTime: undefined
                    createdAt: new Date()
                    msgType: 'system'
                  }
                )
              
              # 发送短信
              if event.isSendSms and user.profile.mobile isnt undefined
                Meteor.call 'sendShortMessage', user.profile.mobile, if status is 'success' then event.message.successSms.replace('#{ticketCode}', ticketCode) else event.message.failSms
        )
      
      if !eventNo || slef.userId is null
        return false
      
      now = new Date()
      event = Events.findOne({eventNo: eventNo})
      user = Meteor.users.findOne(slef.userId)
      if user.profile is undefined
        user.profile = {}
      
      if user.profile.isTestUser is true
        return false
      
      if event is undefined
        throw new Meteor.Error('enterEvent', '不存在此活动！')
      
      # 是否参加过（失败用户可重复参加）
      if event.users isnt undefined and event.users isnt []
        for item in event.users
          if item.id is slef.userId and item.status is 'success'
            throw new Meteor.Error('enterEvent', '已经参加过此活动了！')
            
      # 不在起止时间范围内
      if event.startDate > now or (event.endDate isnt undefined and now > event.endDate)
        throw new Meteor.Error('enterEvent', '活动也过期或未开始！')
        
      # 50的倍数加1为中奖
      if event.users is undefined or event.users is [] or event.users.length <= 0
        return pushUserToEvent('fail')
      else
        count = event.users.length
        if count%50 is 0
          return pushUserToEvent('success')
      
      return pushUserToEvent('fail')
        
      # 以下暂不处理
      # ========================================================================================

      # 每周期有过滤器
      if (event.eachType is 'week' or event.eachType is 'month') and event.eachFilter isnt []
        exist = false
        if event.eachType is 'week'
          for item in event.eachFilter
            if item is now.getDay()
              exist = true
              break
        else if event.eachType is 'month'
          for item in event.eachFilter
            if item is now.getDate()
              exist = true
              break
        
        if !exist
          pushUserToEvent('fail')
          throw new Meteor.Error('enterEvent', '不在活动指定时间内！')     
        
      # 有时间范围
      if event.range isnt []
        exist = false
        for item in event.range        
          start = new Date("#{now.getFullYear()}-#{now.getMonth() + 1}-#{now.getDate()} #{item.end}")
          end = new Date("#{now.getFullYear()}-#{now.getMonth() + 1}-#{now.getDate()} #{item.end}")
            
          # 截止时间是第二天
          if parseInt(item.end.split(':')[0]) < parseInt(item.start.split(':')[0])
            end.setDate(end.getDate()+1)
            if end > event.endDate
              end.setDate(end.getDate()-1)
              end.setHours(23)
              end.setMinutes(59)
              end.setSeconds(59)
            
          if now >= start and now <= end
            exist = true
            break
          
        if !exist
          pushUserToEvent('fail')
          throw new Meteor.Error('enterEvent', '不在活动指定时间内！') 
          
      # 是否超过了最大人数
      if event.maxQuota > 0 and event.users isnt undefined and event.users isnt []
        if event.users.length > event.maxQuota
          pushUserToEvent('fail')
          throw new Meteor.Error('enterEvent', '活动已经束了！')
          
      # 计算当前周期起止时间
      start = null
      end = null

      switch event.eachType
        when 'day'
          start = new Date("#{now.getFullYear()}-#{now.getMonth() + 1}-#{now.getDate()} 00:00:00")
          end = new Date("#{now.getFullYear()}-#{now.getMonth() + 1}-#{now.getDate()} 23:59:59")
        when 'week'
          start = new Date("#{now.getFullYear()}-#{now.getMonth() + 1}-#{now.getDate()} 00:00:00")
          start.setDate(start.getDate()-start.getDay())

          end = new Date("#{now.getFullYear()}-#{now.getMonth() + 1}-#{now.getDate()} 23:59:59")
          if end.getDay() is 0
            end.setDate(end.getDate()+1)
          else
            end.setDate(end.getDate()+(7-end.getDay()-1))
        when 'month'
          start = new Date("#{now.getFullYear()}-#{now.getMonth() + 1}-01 00:00:00")
          end = new Date("#{now.getFullYear()}-#{now.getMonth() + 1}-#{now.getDate()} 23:59:59")

          # 计算当前月的最后一天
          end.setMonth(now.getMonth()+1)
          end.setDate(1)
          end.setDate(end.getDate()-1)
        else throw new Meteor.Error("无效的活动周期类型：#{event.eachType}")

      # 计算准确的起止时间
      if event.range isnt []
        start.setHours(parseInt(event.range[0].start.split(':')[0]))
        start.setMinutes(parseInt(event.range[0].start.split(':')[1]))
        start.setSeconds(parseInt(event.range[0].start.split(':')[2]))
        end.setHours(parseInt(event.range[0].end.split(':')[0]))
        end.setMinutes(parseInt(event.range[0].end.split(':')[1]))
        end.setSeconds(parseInt(event.range[0].end.split(':')[2]))
        
        for item in event.range
          date = new Date(start.toISOString())
          date.setHours(parseInt(item.start.split(':')[0]))
          date.setMinutes(parseInt(item.start.split(':')[1]))
          date.setSeconds(parseInt(item.start.split(':')[2]))
          if date < start
            start = new Date(date.toISOString())
            
          date = new Date(end.toISOString())
          date.setHours(parseInt(item.end.split(':')[0]))
          date.setMinutes(parseInt(item.end.split(':')[1]))
          date.setSeconds(parseInt(item.end.split(':')[2]))
          if date > end
            end = new Date(date.toISOString())
 
        # 修正起止时间
        switch event.eachType
          when 'day'
            # 截止时间是第二天
            if end < start
              end.setDate(end.getDate()+1)
          when 'week'
            # 截止时间是第二天
            if end < start
              date = new Date(end.toISOString())
              date.setDate(date.getDate()+1)
              
              # 第二天不是星期日
              if data.getDay() isnt 0
                end.setDate(end.getDate()+1)
              else
                end.setHours(23)
                end.setMinutes(59)
                end.setSeconds(59)
          when 'month'
            # 截止时间是第二天
            if end < start
              date = new Date(end.toISOString())
              date.setDate(date.getDate()+1)
              
              # 第二天不是每月的第一天
              if data.getMonth() isnt 1
                end.setDate(end.getDate()+1)
              else
                end.setHours(23)
                end.setMinutes(59)
                end.setSeconds(59)
          else throw new Meteor.Error("无效的活动周期类型：#{event.eachType}")

      # 是否超出有效时间范围
      if end > event.endDate
        end = new Date(event.endDate.toISOString())
      if start < event.startDate
        start = new Date(event.startDate.toISOString())
      console.log "event no '#{event.eventNo}' is from '#{start.toLocaleString()}' to '#{end.toLocaleString()}'"
          
      # 计算当前周期参加的人数
      if event.eachQuota > 0 and event.users isnt undefined and event.users isnt []
        quota = 0
        for item in event.users
          if item.status is 'success' and item.enterDate >= start and item.enterDate <= end
            quota += 1
        
        if quota >= event.eachQuota
          pushUserToEvent('fail')
          throw new Meteor.Error('enterEvent', '当期活动已经束了！')
          
      pushUserToEvent('success')
  })