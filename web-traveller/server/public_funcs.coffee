@clearNewCommentsMessage = (wifiID)->
    chatUser = ChatUsers.findOne({
        userId: Meteor.userId(),
        toUserId: wifiID,
        msgTypeEx: 'wifiboard'
    })
    console.log('clearNewCommentsMessage: 1')
    if chatUser isnt undefined and chatUser isnt null
        console.log('clearNewCommentsMessage: 2')
        ChatUsers.update({
            _id: chatUser._id
        },{
            $set:{
                comments: []
            }
        }, (err)->
            console.log("clearNewCommentsMessage: err, "+err);
        )