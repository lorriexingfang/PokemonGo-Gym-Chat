Meteor.startup ()->
  Template.registerHelper 'getUserName', (id)->
    user = Meteor.users.findOne {_id: id}
    
    if user is undefined
      ''
    else if user.profile.nike is undefined or user.profile.nike is ''
      user.username
    else
      user.profile.nike
      
  Template.registerHelper 'getUserPicture', (id)->
    user = Meteor.users.findOne {_id: id}
    if user is undefined
      ''
    else if user.profile.picture is undefined or user.profile.picture is ''
      '/userPicture.png'
    else
      user.profile.picture