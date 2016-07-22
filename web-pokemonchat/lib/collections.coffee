root = exports ? this
root.Posts = new Mongo.Collection('posts')

#root.ChatUsers = new Mongo.Collection("chatUsers")
root.mongoChatUsers = new Meteor.Collection("chatUsers")
root.ChatUsers = mongoChatUsers

root.Wifis = new Mongo.Collection("wifis");
root.WifiPosts = new Mongo.Collection("wifiPosts");
root.WifiUsers = new Mongo.Collection("wifiUsers");
root.Scores = new Mongo.Collection("scores")

if(Meteor.isServer)
  root.RefNames = new Meteor.Collection("refnames")
  
  # 生成测试数据
  if(RefNames.find({}).count() <= 0)
    RefNames.insert({text: '李白'})
    RefNames.insert({text: '赵云'})
    RefNames.insert({text: '大白'})
    RefNames.insert({text: '曹操'})
    RefNames.insert({text: '林冲'})
