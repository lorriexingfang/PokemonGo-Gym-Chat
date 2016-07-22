Meteor.startup(
  ()->
    # ==============初始化消息的系统帐号================
    profile = {
      createdAt: new Date()
      picture: '/userPicture.png'
      isVip: 0
      isAdmin: 0
      isTestUser: false
      isBusiness: 0
      isSystem: true
      isReply: false
    }

    # 1、搭伙小助手
    if(Meteor.users.find({'username': TRAVELLER_HELPER}).count() <= 0)
      profile.nike = '搭伙小助手'
      profile.picture = 'http://bos.youzhadahuo.com/NCauQCC2gy8Faw7Jz_1430881860055.jpg'
      Accounts.createUser({username: TRAVELLER_HELPER, password: (new Mongo.ObjectID())._str, profile: profile})

    # 2、游喳小喇叭
    if(Meteor.users.find({'username': TRAVELLER_BELL}).count() <= 0)
      profile.nike = '游喳小喇叭'
      profile.picture = 'http://bos.youzhadahuo.com/NCauQCC2gy8Faw7Jz_1430881838692.jpg'
      Accounts.createUser({username: TRAVELLER_BELL, password: (new Mongo.ObjectID())._str, profile: profile})

    # 3、搭伙消息
    if(Meteor.users.find({'username': TRAVELLER_MESSAGE}).count() <= 0)
      profile.nike = '搭伙消息'
      profile.picture = 'http://bos.youzhadahuo.com/NCauQCC2gy8Faw7Jz_1430881884857.jpg'
      Accounts.createUser({username: TRAVELLER_MESSAGE, password: (new Mongo.ObjectID())._str, profile: profile})

    # 4、本地资讯
    if(Meteor.users.find({'username': TRAVELLER_NEWS}).count() <= 0)
      profile.nike = '本地资讯'
      profile.picture = 'http://bos.youzhadahuo.com/NCauQCC2gy8Faw7Jz_1433497829161.jpg'
      Accounts.createUser({username: TRAVELLER_NEWS, password: (new Mongo.ObjectID())._str, profile: profile})

    # 4、系统消息
    if(Meteor.users.find({'username': TRAVELLER_SYSTEM}).count() <= 0)
      profile.nike = '系统消息'
      profile.picture = 'http://bos.youzhadahuo.com/NCauQCC2gy8Faw7Jz_1430881884857.jpg'
      Accounts.createUser({username: TRAVELLER_SYSTEM, password: (new Mongo.ObjectID())._str, profile: profile})

    # 5. SecureCloneBox
    if(Meteor.users.find({'username': TRAVELLER_SECURECLONEBOX}).count() <= 0)
      profile.nike = '克隆大密盒'
      profile.picture = 'http://bos.youzhadahuo.com/NCauQCC2gy8Faw7Jz_1430881884857.jpg'
      Accounts.createUser({username: TRAVELLER_SECURECLONEBOX, password: (new Mongo.ObjectID())._str, profile: profile})
)
