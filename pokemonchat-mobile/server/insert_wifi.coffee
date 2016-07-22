# Meteor.startup ()->
# # 只能作为本地开发测试
# if(Meteor.users.find({'business.wifi.0': {$exists: true}}).count() <= 0)
#   Meteor.users.find({}, {limit: 5}).forEach(
#     (user)->
#       console.log('insert test wifi data.')
#       Meteor.users.update(
#         {_id: user._id}
#         {
#           $set: {
#             'profile.isBusiness': 1
#             'profile.business': '一米阳光'
#             'profile.address': '丽江古城大研镇'
#             'profile.text': '商家介绍...'
#             'business.wifi': [{
#               BSSID: '01-02-03-04-45'
#               IPAddress: ''
#               MacAddress: ''
#               SSID: 'test-wifi'
#             }]
#             'business.users': []
#             'business.reports': []
#             'business.readCount': 0
#             'business.typeImage': '/wifi/006.png'
#             'business.titleImage': '/home/group1/01.jpg'
#           }
#         }
#       )
#   )