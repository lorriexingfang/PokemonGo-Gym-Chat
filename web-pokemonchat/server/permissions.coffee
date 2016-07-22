if Meteor.isServer
  Wifis.allow
    update: (userId, doc, fieldNames, modifier)->
      true

